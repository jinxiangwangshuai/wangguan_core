
local json = require('cjson')

RPCS = RPCS or {
	responseFun = nil,  -- 回复函数，参数为msg，将数据通过通信方式返回给client端
	notifyFun = nil,    -- 通知函数，参数msg，将数据通过通信方式通知给client端
	filters = nil, 		-- 过滤器，如果一个系统内有多个RPCS，通过filter进行过滤
}

-- 在使用rpc之前，先将一些通信函数等参数注册进来
function RPCS.register(param)
	if param.responseFun then
		RPCS.responseFun = param.responseFun
	end
	
	if param.notifyFun then
		RPCS.notifyFun = param.notifyFun
	end
end

-- 设置过滤器, 参数可以是一个字符串，也可以是数组
function RPCS.filterConfig(filters)
	RPCS.filters = filters
end

local function response(messageId, result, error, method, params)
	if RPCS.responseFun == nil then return end
	if messageId == nil then return end
	
	local resp = {
		messageId = messageId,
		method = method,
	}
	
	if result == nil then
		resp.result = 'error'
		resp.error = 'unknown'
	else
		resp.result = result
		if error then
			resp.error = error
		end
	end
	
	if params then
		resp.params = params
	end
	
	RPCS.responseFun(json.encode(resp))
end

-- 消息过来时，通过这个函数进行统一处理
function RPCS.process(msg)
	if msg == nil then return end
	local data = json.decode(msg)
	if data == nil or data.messageId == nil then return end
	
	-- 查看是否有过滤器，当不匹配时，直接退出
	if data.filter ~= nil then
		if RPCS.filters == nil then return end
		local t = type(RPCS.filters)
		if t == 'string' then
			if data.filter ~= RPCS.filters then return end
		elseif t == 'table' then
			local match = false
			for k, v in pairs(RPCS.filters) do
				if v == data.filter then break end
			end
			if match == false then return end
		end
	elseif RPCS.filters ~= nil then
		return
	end
	local params = data.params
	local method = data.method

	if RPCS[method] == nil then
		response(data.messageId, 'error', 'method not found', nil)
		return
	end
	
	local respResult, respError, respParams = RPCS[method](params)
	response(data.messageId, respResult, respError, method, respParams)
end


function RPCS.notify(notify, params)
	if notify == nil then return end
	if RPCS.notifyFun == nil then return end
	local msg = {
		notify = notify,
	}
	
	if params ~= nil then
		msg.params = params
	end
	RPCS.notifyFun(json.encode(msg))
end
