#! /usr/bin/env lua

module(..., package.seeall)

local class = require("class")
local ex = require("exception").install(_M)

local function trim(str)
	return (str:gsub("^%s*(.*%S)%s*$", "%1"))
end
local function cond(test, val1, val2)
	if test then return val1 else return val2 end
end

stack = class{
	_top = 0;
	push = function(self, name, ...)
	--	print("PUSH", self, name)
		self._top = self._top + 1
		name = name or self._top
		self[self._top] = name
		if type(name)=="string" then
			self[name] = self._top
		end
		return name
	end;
	pop = function(self, ...)
	--	print("POP", self)
		local name = table.remove(self)
		self._top = self._top - 1
		if self[name] then
			self[name] = nil
		end
		return name
	end;
	getindex = function(self, name, ...)
	--	print("GET", self, name)
		local i = name
		if type(name)=="string" then
			i = self[name]
		end
		if not i then return false end
		return -self._top + i - 1
	end;
	clean = function(self)
	--	print("CLEAN", self)
		self._top=0;
	end;
}

concatstring = class{
	__class="concatstring";
	sep="";
	atbegin="";
	atend="";
	insert = table.insert;
	remove = table.remove;
	concat = table.concat;
	__tostring = function(self)
		local atbegin, atend = self.atbegin, self.atend
		if #self == 0 then
			atbegin = ""
			atend   = ""
		end
		return atbegin..self.concat(self, self.sep)..atend
	end;
	tostring = function(self)
		return self:__tostring();
	end;
}

object=class{
	__class = "object";
	_sub = {};
	_ind = "";   -- tab to apply to self
	_tab = "\t"; -- tab to apply to childs
	_eol = "\n";
	insert = table.insert;
	remove = table.remove;
	insertp = function(self, pos, elem)
		if not elem then
			elem = pos
			pos = nil
		end
		if not self.insertp_class then
			self.insertp_class = class(self, {
				__tostring = function(self)
					return
						self._parent._ind
						..self[1]
						..self._parent._eol
				end;
			})
		end
		if pos
		then return self:insert(pos, self.insertp_class{elem})
		else return self:insert(     self.insertp_class{elem})
		end
	end;
	propagate = function(self, k, v) end;
	__init = function(self) end;
	concat = function(self)
		local buf = concatstring{}
		local applyeol = true
		for k, v in ipairs(self) do
			if v == nil then
				-- pass
			elseif type(v) == "table" then
				v._parent = self
				try(function()
					v._ind = self._ind .. self._tab .. v._ind
				end, ex.null)
				self:propagate(k, v)
				try(function()
					v:__init()
				end, ex.null)
				buf:insert(tostring(v))
			else
				buf:insert(self._ind .. self._tab)
				buf:insert(tostring(v))
				buf:insert(self._eol)
			end
		end
		return buf:tostring()
	end;
	__tostring = function(self)
		return self:tostring();
	end;
	tostring = function(self)
		return self:concat();
	end;
	namestack = function(self, name)
		name = type(name)=="number" and "<"..tostring(name)..">" or name
		return self:comment("PUSH", name)
	end;
	comment = function(...)
		local buf = concatstring{ atbegin=" // "; sep=" " }
		for k, v in pairs({...}) do
			if type(v)=="string"
			then buf:insert(v)
			elseif type(v)=="number"
			then buf:insert(tostring(v))
			end
		end
		return buf:tostring()
	end;
}

inline = class({
	__class = "inline";
	_tab = "";
})
block = class({
	__class = "block";
	_tab = "\t";
})

cfile = class(object, inline, {
	__class = "cfile";
	luadir = "";
	tostring = function(self)
		self:insert(1, ("#include <%slua.h>"):format(self.luadir))
		self:insert(2, ("#include <%slualib.h>"):format(self.luadir))
		self:insert(3, ("#include <%slauxlib.h>"):format(self.luadir))
		self:insert(4, "")
		self:insert(   "")
		return self:concat()
	end;
})

blockcode = class(object, inline, {
	__class = "blockcode";
	tostring = function(self)
		for k, v in ipairs(self) do
			local space = v:sub(v:find("%s*")):gsub("^%s*[\r\n]+", "")
			self[k] = trim(v:gsub("[\r\n]+"..space, self._eol..self._ind))
		end
		return self:concat()
	end;
})

cfunction_params = class(concatstring, {
	__class="cfunction_params";
	sep=", ";
})
cfunction_keywords = class(concatstring, {
	__class="cfunction_keywords";
	sep=" ";
	atend=" ";
})

cfunction = class(object, block, {
	__class = "cfunction";
	keywords= cfunction_keywords{};
	ctype   = "void";
	--cname   = "main";
	cparam  = cfunction_params{};
	format_function_begin = "%s%s %s (%s) {";
	format_function_end   = "}";
	tostring = function(self)
		self:insertp(1, self.format_function_begin:format(
			self.keywords:tostring(),
			self.ctype,
			self.cname or self.name,
			self.cparam:tostring()))
		self:insertp(   self.format_function_end)
		return self:concat()
	end;
})

clfunction = class(cfunction, {
	__class = "clfunction";
	ctype = "int";
	--cname = "lua_foo";
	cparam= cfunction_params{ "lua_State* L" };
	format_function_begin = "%s%s %s (%s) {";
	--stack = stack{};
	__init = function(self)
		self.stack = stack{};
	end;
	propagate = function(self, k, v)
		v.stack = self.stack
	end;
})

creturn = class(object, inline, {
	__class="creturn";
	return_format="return %s;";
	tostring = function(self)
		local t = type(self[1])
		if t == "nil" then
			self[1] = self.return_format:format("")
		elseif t == "number" then
			self[1] = self.return_format:format(("%g"):format(self[1]))
		else
			self[1] = self.return_format:format("")
		end
		return self:concat()
	end;
})

usertype = class(object, block, {
	__class = "usertype";
	_tab    = "\t\t";
	uri     = "local:///not-valid"; -- the URI
	cname   = nil;                  -- the identifier of the function
	ctype   = "void*";
	cparam  = concatstring{ sep=", "; "lua_State* L" };
	keywords= concatstring{ sep=" "; atend=" " };
	stack   = stack{};
	format_function_name  = "lusertype_%s";
	format_function_begin = "%sint lusertype_%s (%s) {";
	format_begin          = "\tif(luaL_newmetatable(L, %q)){";
	format_end            = "\t}";
	format_function_return= "\treturn 1;";
	format_function_end   = "}";
	tostring = function(self)
		self:insertp(1, self.format_function_begin:format(
			self.keywords:tostring(),
			self.cname or self.name,
			self.cparam:tostring()))
		self:insertp(2, self.format_begin:format(self.uri)
			..self:namestack(self.stack:push(self.name or self.cname)))
		self:insertp(   self.format_end)
		self:insertp(   self.format_function_return)
		self:insertp(   self.format_function_end)
		return self:concat()
	end;
	propagate = function(self, k, v)
		v.stack = self.stack
	end;
	pushmetatable_class = class(object, inline, {
		__class="usertype.pushmetatable_class";
		tostring = function(self)
			local p = self.parent
			local sname = self.name or p.name or p.cname
			self:insert(p.format_function_name:format(
				p.cname or p.name)
				.."(L);"..self:namestack(self.stack:push(sname)))
			return self:concat()
		end;
	});
	pushmetatable = function(self, t)
		t = t or {}
		t.parent = self
		return self.pushmetatable_class(t)
	end;
})

checkusertype = class(object, inline, {
	__class="checkusertype";
	cname = "self";
	stacknum = 1;
	check_format="%s* %s = (%s*) luaL_checkudata(L, %i, %q);";
	tostring = function(self)
		local usertype = self[1]
		assert(type(usertype)=="table", "wrong_parameter", "self[1] must be a table")
		assert(usertype.__class=="usertype", "wrong_parameter", "self[1] must be a usertype")
		self[1] = self.check_format:format(
			usertype.ctype,
			self.cname,
			usertype.ctype,
			self.stacknum,
			usertype.uri
			)..self:namestack(self.stack:push(self.name or self.cname))
		return self:concat()
	end;
})
checkusertypeP = class(object, inline, {
	__class="checkusertypeP";
	check_format="%s %s = *((%s*) luaL_checkudata(L, %i, %q));";
})

local checkany = class(object, inline, {
	__class="checkany";
	cname = "string";
	stacknum = 1;
	check_ctype="void";
	check_function="luaL_check...";
	check_format="%s %s = %s(L, %i);";
	tostring = function(self)
		self[1] = self.check_format:format(
			self.check_ctype,
			self.cname,
			self.check_function,
			self.stacknum
			)..self:namestack(self.stack:push(self.name or self.cname))
		return self:concat()
	end;
})
checkstring = class(checkany, {
	__class="checkstring";
	check_ctype="const char*";
	check_function="luaL_checkstring";
})
checklstring = class(checkany, {
	__class="checklstring";
	check_ctype="const char*";
	check_function="luaL_checklstring";
	check_format="%s %s = %s(L, %i, %s);";
	tostring = function(self)
		self[1] = self.check_format:format(
			self.check_ctype,
			self.cname,
			self.check_function,
			self.stacknum,
			self.cname_len
			)..self:namestack(self.stack:push(self.name or self.cname))
		return self:concat()
	end;
})
checkint = class(checkany, {
	__class="checkint";
	check_ctype="int";
	check_function="luaL_checkint";
})
checklong = class(checkany, {
	__class="checklong";
	check_ctype="long";
	check_function="luaL_checklong";
})
checknumber = class(checkany, {
	__class="checknumber";
	ctype="lua_Number";
	check_function="luaL_checknumber";
	check_format="%s %s = (%s) %s(L, %i);";
	tostring = function(self)
		self[1] = self.check_format:format(
			self.ctype,
			self.cname,
			self.ctype,
			self.check_function,
			self.stacknum
			)..self:namestack()self.stack:push(self.name or self.cname)
		return self:concat()
	end;
})
checkinteger = class(checknumber, {
	__class="checkinteger";
	ctype="lua_Integer";
	check_function="luaL_checkinteger";
})
checktype = class(checkany, {
	__class="checktype";
	check_function="luaL_checktype";
	check_format="%s(L, %i);";
	tostring = function(self)
		raise("not_implemented")
		self[1] = self.check_format:format(
			self.check_function,
			self.stacknum
			)..self:namestack(self.stack:push(self.name or self.cname))
		return self:concat()
	end;
})

newusertype = class(object, inline, {
	__class="newusertype";
	--cname = "userdata";
	format="%s* %s = (%s*) lua_newuserdata(L, sizeof(%s));";
	tostring = function(self)
		local usertype = self[1]
		assert(type(usertype)=="table", "wrong_parameter", "self[1] must be a table")
		assert(usertype.__class=="usertype", "wrong_parameter", "self[1] must be a usertype")
		self[1] = self.format:format(
			usertype.ctype,
			self.cname or self.name,
			usertype.ctype,
			usertype.ctype
			)..self:namestack(self.stack:push(self.name or self.cname))
		return self:concat()
	end;
})

pushlua = class(object, inline, {
	__class="pushlua";
	tostring = function(self)
		for k, v in ipairs(self) do
			local t = type(v)
			local name =
				(type(self.name)=="table" and self.name[k])
				or self.name
				or ("%s-%i-%s"):format(self.__class, k, tostring(v))
			if self.limit and k > self.limit then
				v = nil
			elseif t == "nil" then
				v = "lua_pushnil(L);"
					..self:namestack(self.stack:push(name))
			elseif t == "number" then
				local f = "lua_pushnumber(L, %g);"
				v = f:format(v)
					..self:namestack(self.stack:push(name))
			elseif t == "string" then
				local f="lua_pushlstring(L, %q, %i);"
				v = f:format(v, #v)
					..self:namestack(self.stack:push(name))
			elseif t == "function" then
				local dump = string.dump(v)
				local data = ("%q"):format(dump)
					:gsub("\\\n", "\\n")
					:gsub("\\\r", "\\r")
					:gsub("\\\t", "\\t")
				--local data = concatstring{ '"' }
				--for i = 1, #dump do
				--	local c = dump:sub(i, i)
				--	local b = c:byte()
				--	data:insert(b>=32 and b<=127 and
				--		(c=='"' and '\\"' or c) or
				--		("\\x%02x"):format(b))
				--end
				--data:insert( '"' )
				--data = data:tostring()
				f = "luaL_loadbuffer(L, %s, %i, %q);"
				v = f:format(data, #dump, name)
					..self:namestack(self.stack:push(name))
			else
				raise("cant_serialize",
					("can't serialize the value given at position %i : %s"):format(k, tostring(v)))
			end
			self[k]=v
		end
		return self:concat()
	end;
})

pushcfunction = class(object, inline, {
	__class="pushcfunction";
	tostring = function(self)
		for k, v in ipairs(self) do
			if self.limit and k > self.limit then break end
			if type(v)=="table" and v.__class=="clfunction" then
				v = v.cname or v.name
			end
			assert(type(v)=="string", "type_error", "any value must be a string")
			local name =
				(type(self.name)=="table" and self.name[k])
				or self.name
				or ("%s-%i-%s"):format(self.__class, k, v)
			local f = "lua_pushcfunction(L, %s);"
			self[k] = f:format(v)
				..self:namestack(self.stack:push(name))
		end
		return self:concat()
	end;
})

pushvalue = class(object, inline, {
	__class = "pushvalue";
	tostring = function(self)
		local val
		if type(self[1])~="number" then
			val = ex.assert(self.stack:getindex(self[1]),
				"unknown_stackname",
				("the stackname '%s' can't be found."):format(self[1]))
		else
			val = self[1]
		end
		
		self[1] = ("lua_pushvalue(L, %i); // GET %s")
			:format(val, self[1])
			..self:namestack(self.stack:push(self.name))
		return self:concat()
	end;
})

showstack = class(object, inline, {
	__class = "showstack";
	tostring = function(self)
		local buf = concatstring{
			("/// STACK[%i]:"):format(self.stack._top);
			sep=" " }
		for k, v in ipairs(self.stack) do
			buf:insert(type(v)=="string" and v or "<"..tostring(k)..">")
		end
		if self.stack._top == 0 then buf:insert("(empty)") end
		self:insert(buf:tostring())
		return self:concat()
	end;
})

stackpop = class(object, inline, {
	__class = "stackpop";
	tostring = function(self)
		self.stack._top = self.stack._top - self[1]
		return nil
	end;
})
stackpush = class(object, inline, {
	__class = "stackpop";
	tostring = function(self)
		if type(self[1])=="number" then
			self.stack._top = self.stack._top + self[1]
		else
			self.stack:push(self[1])
		end
		return nil
	end;
})
stackset = class(object, inline, {
	__class = "stackpop";
	tostring = function(self)
		self.stack._top = self[1]
		return nil
	end;
})

pushtable = class(object, inline, {
	__class = "pushtable";
	nrec=0;
	narr=0;
	format="lua_createtable(L, %i, %i); // narr, nrec";
	tostring = function(self)
		local sname = self.stack:push(self.name)
		local str = self:concat()
		str = self._ind..self.format:format(self.narr,self.nrec)
			..self:namestack(sname)..self._eol..str
		return str
	end;
	propagate = function(self, k, v)
		try(function()
			assert(v.__class=="pair")
			local narr, nrec = v:keyType()
			self.narr = self.narr + narr
			self.nrec = self.nrec + nrec
		end, ex.null)
		v.stack = self.stack
	end;
})

pair = class(object, inline, {
	__class = "pair";
	tostring = function(self)
		self:insert("lua_settable(L, -3); // POP 2");
		local str = self:concat()
		self.stack:pop()
		self.stack:pop()
		return str
	end;
	propagate = function(self, k, v)
		v.stack = self.stack
		v.limit = 1
	end;
	keyType = function(self)
		local t = try(function()
			assert(self[1].__class=="pushlua")
			return type(self[1][1])
		end, function(...)
			return "unknown";
		end)
		return cond(t=="number", 1, 0), cond(t=="string", 1, 0)
	end;
})

sp="";

function install(level)
	level = level or 1
	local G = getfenv(level+1)
	setfenv(level+1, _M)
	return G, _M
end

