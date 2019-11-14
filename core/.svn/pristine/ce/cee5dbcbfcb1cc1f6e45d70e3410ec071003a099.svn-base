-- lua list template

local List = {}

local modelName = 'list'
_G[modelName] = List
setmetatable(List, {__index = _G})
--setfenv(1, List)

--[[
function List.new()
    return {first = 0, last = -1}
end

function List.pushleft(list, value)
    local first = list.first - 1
    list.first = first
    list[first] = value
end

function List.pushright(list, value)
    local last = list.last + 1
    list.last = last
    list[last] = value
end

function List.popleft(list)
    local first = list.first
    if first > list.last then return nil end
    local value = list[first]
    list[first] = nil -- to allow garbage collection
    list.first = first + 1
    return value
end

function List.popright(list)
    local last = list.last
    if list.first > last then return nil end
    local value = list[last]
    list[last] = nil -- to allow garbage collection
    list.last = last - 1
    return value
end

function List.isEmpty(list)
	if list.first > list.last then return true end
	return false
end
--]]

function _isTableNull(t)
	if t == nil then return true end
	if type(t) ~= 'table' then return true end
	if next(t) ~=nil then 
		return false
	end
	return true
end

function List.new()
    return {}
end

function List.pushright(list, value)
	if _isTableNull(list) == true then
		list[1] = value
		return
	end
	
	local len = #list
	list[len + 1] = value
end

function List.popleft(list)
	if _isTableNull(list) == true then
		return nil
	end
	
	local value = list[1]
	list[1] = nil
	table.remove(list, 1)
	return value
end

function List.isEmpty(list)
	return _isTableNull(list)
end

function List.print(list)
	if List.isEmpty(list) == true then print('empty') end
	for k, v in ipairs(list) do
		print('-- ', k, v)
	end
end

return List
