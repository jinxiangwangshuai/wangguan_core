local socket = require "socket"

IHB = IHB or {
	timeCount = 0,
	heartCount = 0,
}

local enabled = true
local monitors = {}
--[[
local m = {
	name = 'example',
	maxTime = 60,
	count = 0,
}
--]]

local function systemReboot()
	--log.print('red', 'system reboot!')
	socket.sleep(1)
	os.execute('sync')
	os.execute('reboot')
end

function IHB.setEnabled(e)
	enabled = e
end

function IHB.msgProcess(msg)
	if msg.action == 'heartbeat' then
		IHB.heartCount = 0
	elseif IHB[msg.action] ~= nil then
		IHB[msg.action](msg)
	end
end

function IHB.register(config)
	local name = config.name
	if name == nil or config.maxTime == nil then return end
	if monitors[name] == nil then
		monitors[name] = {
			name = name,
			maxTime = config.maxTime,
			count = 0
		}
	else
		monitors[name].maxTime = config.maxTime
		monitors[name].count = 0
	end
end

function IHB.feed(msg)
	local name = msg.name
	if name == nil then return end
	if monitors[name] ~= nil then
		monitors[name].count = 0
	end
end

local function checkAll()
	for k, v in pairs(monitors) do
		monitors[k].count = monitors[k].count + 1
		if monitors[k].count >= monitors[k].maxTime then
			monitors[k].count = 0
			log.fatal('!! ['..k..'] cannot rev inside heartbeat more than ' .. monitors[k].maxTime .. 's, then reboot system')
			systemReboot()
			return
		end
	end
end

function IHB.loop(t) -- t is ms
	if enabled == false then return end
	IHB.timeCount = IHB.timeCount + t
	if IHB.timeCount >= 1000 then
		IHB.timeCount = 0
		IHB.heartCount = IHB.heartCount + 1
		checkAll()
		if IHB.heartCount > 30 then -- 超过30s没收到内部心跳，说明系统网络已经坏掉了，直接重启
			log.fatal('!!!! cannot rev inside heartbeat more than 30s, then reboot system')
			systemReboot()
			IHB.heartCount = 0
		end
	end
end
