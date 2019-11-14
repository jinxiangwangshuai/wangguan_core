#! /usr/bin/env lua

local _G = _G

return function(...)
	local c = {}
	local m = {}
	_G.setmetatable(c, m)
	for i = 1, _G.select('#', ...) do
		_G.assert(_G.type(_G.select(i, ...)) == "table",
		       "invalid_parameter",
		       "invalid base class specified")
		for k, v in _G.pairs(_G.select(i, ...)) do
			c[k] = v
		end
	end
	c.__index = c
	function m:__call(obj)
		obj = obj or {}
		_G.setmetatable(obj, c)
		return obj
	end
	return c
end
