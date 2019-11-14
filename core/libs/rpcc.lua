package.path = package.path .. ";./?.lua;../libs/?.lua;/home/share/core/libs/?.lua;/home/share/core/?.lua"
package.cpath = package.cpath..";./?.so;../libc/?.so;/home/share/core/libc/?.so"

require 'common'
local Timer = require 'Timer'
local timer = Timer()

-- tools
local function random(n, m)
    math.randomseed(os.clock()*math.random(1000000,90000000)+math.random(1000000,90000000))
    return math.random(n, m)
end

local function randomNumber(len)
    local rt = ""
    for i=1,len,1 do
        if i == 1 then
            rt = rt..random(1,9)
        else
            rt = rt..random(0,9)
        end
    end
    return rt
end

local function randomLetter(len)
    local rt = ""
    for i = 1, len, 1 do
        rt = rt..string.char(random(97,122))
    end
    return rt
end
-- end tools

local cache = {}
local cacheLen = 50

local RPCC = {
	timeout = 3000, -- 3s
	sendFunction = nil, -- send function(msg)
}

local function uuid()
	return randomLetter(16)
end

local function isNull(p)
	if p == nil then
		return true
	else
		return false
	end
end

-- 调用远程函数
-- method 函数名
-- params 传入参数
-- callback 返回结果以callback方式
function RPCC.call(method, params, callback, filter)
	if RPCC.sendFunction == nil then
		print('rpcc: sendFunction canot be null!')
		return
	end
	
	if method == nil then
		print('rpcc: method canot be null!')
		return
	end
	
	local msg = {
		messageId = uuid(),
		method = method,
	}
	if params ~= nil then
		msg.params = params
	end
	if filter ~= nil then
		msg.filter = filter
	end
	
	if callback ~= nil and type(callback) == 'function' then
		local item = {
			timeout = 0,
			messageId = msg.messageId,
			method = method,
			callback = callback,
		}
		if params ~= nil then
			item.params = params
		end
		if filter ~= nil then
			item.filter = filter
		end
		
		for i = 1, cacheLen, 1 do
			if cache[i] == nil then
				cache[i] = item
				RPCC.sendFunction(table2json(msg))
				return
			end
		end
	end
end

-- 处理接收来的消息
function RPCC.process(msg)
	if msg == nil then return end
	
	local response = json2table(msg)
	if response == nil then
		print("rpcc process: param is not json!");
		return;
	end
	
	local messageId = response.messageId
	
	for i = 1, cacheLen, 1 do
		if cache[i] ~= nil then
			if messageId == cache[i].messageId then
				cache[i].callback(response)
				cache[i] = nil
				return
			end
		end
	end
end

local function rpccCheckTimeout()
	for i = 1, cacheLen, 1 do
		if cache[i] ~= nil then
			cache[i].timeout = cache[i].timeout + 100 -- 100ms one timer out
			if cache[i].timeout > RPCC.timeout then
				local resp = {
					result = 'error',
					error = 'timeout',
				}
				cache[i].callback(resp)
				cache[i] = nil
				return
			end
		end
	end
end
local checkTimer = timer:every(100, rpccCheckTimeout, -1) -- 100ms to check once

function RPCC.loop(t)
	timer:update(t)
end

return RPCC
