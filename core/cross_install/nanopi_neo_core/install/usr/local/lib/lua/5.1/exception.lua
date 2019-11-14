#! /usr/bin/env lua

-- module
local _NAME = ...
local _M = { _M=_M, old={}}

-- access to standard functions
local _G = _G
_M.old = {
	traceback = _G.debug.traceback;
	error = _G.error;
}


-- upvalues
local lasterror
local exception_mt = {}
function exception_mt.__tostring(t)
	local res = ""
	if t.location ~= "" then res = res .. t.location .. ": " end
	if t.error == t.message
	then res = res .. tostring(t.error)
	else res = res .. ("%s (%s)"):format(t.error, t.message)
	end
	return res
	--return ("%s: %s (%s)"):format(t.location, t.error, t.message)
end;
function exception_mt.__index(t, k)
	if k == "display" then
		return exception_mt.__tostring(t)
	elseif k == "message" then
		return t.error
	end
	return ""
end;
exception_mt.type="http://purl.org/NET/louve/2006/0403/luaexception";


function _M.isexception(e)
	local mt = _G.getmetatable(e) or {}
	return (mt.type=="http://purl.org/NET/louve/2006/0403/luaexception")
end

function _M.traceback(level)
	level = level or 1
	local tb = (_M.old.traceback("", level+1):gsub("%s+stack traceback:%s+", "\t"))
	return tb, tb:sub(2, (tb:find(": ", 1, true))-1)
end

function _M.raise(...) -- e, level -- error, errormessage, level
	local e, level = ...
	e = e or lasterror
	if _M.isexception(e) then
		-- the exception already exists
		level = level or 1
		local title = ("    continue: %s\n"):format(e.error, e.message)
		e.traceback = e.traceback..title..(_M.traceback(level+1))
	else
		-- new exception
		e = { error="error", message=""}
		setmetatable(e, exception_mt)
		e.error, e.message, level = ...
		level = level or 1
		e.traceback, e.location = _M.traceback(level+1)
		e.traceback = ("    raise: %s\n"):format(e.error, e.message)..e.traceback
	end
	return _M.old.error(e, level+1)
end

function _M.show(e)
	_G.print(e)
	return true
end
function _M.null(e)
	return true
end

local function add_traceback(e)
	local tb, loc = _M.traceback(2)
	if _M.isexception(e) then
		e.traceback=e.traceback.."\n"..tb
	else
		-- convert to an exception
		local err = tostring(e)
		local split = (err:find(": ", 1, true)) or 0
		e = {}
		e.error = err:sub(split+2)
		e.message = e.error
		e.location = err:sub(1, split-1)
		e.traceback = ("    raise: %s\n"):format(e.error, e.message)..tb
		setmetatable(e, exception_mt)
	end
	return e
end
function _M.try(try, handler)
	local t, b, tb
	handler = handler or _M.show
	t, tb = {_G.xpcall(try, add_traceback)}, _M.traceback()
	b = _G.table.remove(t, 1)
	if b then return _G.unpack(t) end
	-- if error
	lasterror = t[1]
	-- now delete the last part of the traceback (root to this function)
	lasterror.traceback = lasterror.traceback:sub(1, #lasterror.traceback-#tb)
	t = {handler(lasterror)}
	b = _G.table.remove(t, 1)
	--if b ~= false then -- true value or nil
	if b then -- any true value, NOT nil
		-- no error
		lasterror = nil
		return _G.unpack(t)
	end
	-- if error not solved by the handler
	local e, lvl = _G.unpack(t)
	lvl = lvl or 1
	_M.raise(e, lvl+1)
end

function _M.assert(b, ...)
	if b then return b, ... else return _M.raise(...) end
end

function _M.traceback_toinstall(e, level)
	if _M.isexception(e) then
		return e.display.."\nstack traceback:\n"..e.traceback
	else
		return _M.old.traceback(e, level+1)
	end
end

local already_installed = {}
function _M.install(G, complete)
	G = G or _G
	local G_id = tostring(G)
	if already_installed[G_id] then
		return false,
			"already_installed",
			("The module %s is already installed"):format(_NAME)
	end
	already_installed[G_id] = true
	if not G.debug then
		_M.old.debug = G.debug
		G.debug = {}
	end
	G.debug.traceback = _M.traceback_toinstall
	if complete ~= false then -- nil=true
		-- save
		_M.old.raise  = G.raise
		_M.old.assert = G.assert
		_M.old.try    = G.try
		_M.old[_NAME] = G[_NAME]
		-- install
		G.raise  = _M.raise
		G.assert = _M.assert
		G.try    = _M.try
		G[_NAME] = _M
	end
	return _M
end

function _M.uninstall(G, complete)
	G = G or _G
	G.debug.traceback = _M.old.traceback
	if complete ~= false then -- nil=true
		G.raise  = _M.old.raise
		G.assert = _M.old.assert
		G.try    = _M.old.try
		G[_NAME] = _M.old[_NAME]
		if _M.old.debug then
			G.debug = _M.old.debug
		end
	end
end

return _M