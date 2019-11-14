
local Vector = {}
Vector.__index = Vector

local function _isTableNull(t)
	if t == nil then return true end
	if type(t) ~= 'table' then return true end
	if next(t) ~=nil then 
		return false
	end
	return true
end

function Vector.new()
	local self = {
		list = {}
	}
	return setmetatable(self, Vector)
end

function Vector:push(item)
	if item == nil then return end
	if _isTableNull(self.list) == true then
		self.list[1] = item
		return
	end
	
	local len = #self.list
	self.list[len + 1] = item
end

function Vector:pop()
	if _isTableNull(self.list) == true then
		return nil
	end
	
	local item = self.list[1]
	self.list[1] = nil
	table.remove(self.list, 1)
	return item
end

function Vector:isEmpty()
	return _isTableNull(self.list)
end

function Vector:print()
	if self:isEmpty(self.list) == true then print('empty') end
	for k, v in ipairs(self.list) do
		print('-- ', k, v)
	end
end

return setmetatable({}, {__call = function(_, ...) return Vector.new(...) end})
