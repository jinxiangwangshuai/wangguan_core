-- https://blog.csdn.net/tutuboke/article/details/28386959
luaQueue = {}--class("luaQueue", base)
print = log
 
function luaQueue:new()
	o = o or {}
	setmetatable(o, luaQueue)
	self.__index = luaQueue
	
	local lst = {pre = nil, next = nil, value = nil}
	self.first = nil
	self.last = nil
	self.size = 0
	return o
end
--空返回 true 
function luaQueue:isEmpty()
	if self.size == 0 and self.first == nil and self.last == nil then
		return true
	end
	return false
end
 
function luaQueue:pushFirst(data)
	local lst = {}
	lst.pre = nil
	lst.value = data
	lst.next = nil
	if self.first == nil then
		self.first = lst
		self.last = lst
	else
		lst.next = self.first
		self.first.pre = lst
		self.first = lst
	end
	self.size = self.size + 1
end
 
function luaQueue:popLast()
	if self:isEmpty() then
		print("list is isEmpty")
		return
	end
 
	local popData = self.last
 
 
	local temp = popData.pre
	if temp then
		temp.next = nil
		self.last = temp
	else
		self.last = nil
		self.first = nil
	end
	self.size = self.size - 1
	return popData
end
 
function luaQueue:getQueueData(data)
	return data.value
end
 
function luaQueue:printEveryOne()
	local temp = self.first
	if not temp then
		print("lua Queue is empty")
		return
	end
	while temp do
		print(temp.value)
		temp = temp.next
	end
end
