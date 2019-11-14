package.path = package.path .. ";./?.lua;../libs/?.lua;/home/share/core/libs/?.lua;/home/share/core/base/?.lua"
package.cpath = package.cpath..";./?.so;../libc/?.so;/home/share/core/libc/?.so"

require "common"
require "mymqtt"
local socket = require "socket"
--local netcheck = require 'netcheck'
local log = require "logclient"

local g_isNetOK = nil
local g_gwip = nil

socket.sleep(10)

log.enable(true)
log.printEnable(true)
log.setFrom('net_check')
log.registSendFun(function(topic, m)
		MYMQ.publish(topic, m)
	end
)

local function readShell(cmd)
	if cmd == nil then return nil end
	local t = io.popen(cmd)
	if t == nil then return nil end
	local content = t:read("*a")
	t:close()
	if content ~= nil then
		content=string.gsub(content, "\n", "")
	end
	return content
end

-- wait to get gateway ip
while true do
	local ip = get_gateway()
	if ip == nil then
		print('cannot get current gw ip')
		socket.sleep(1)
	else
		g_gwip = ip
		print('current gw ip', g_gwip)
		break
	end
end

--netcheck.setCheckIP(g_gwip)

local function isNetOK()
	local cmd = 'ping ' .. g_gwip .. ' -c 1 -w 2 | grep icmp_seq'
	local result = readShell(cmd)
	if result == nil or string.len(result) < 3 then
		return false
	end
	return true
end

local function ledNotify(isNetOK)
	local msg = {
		action = 'set',
		cmd = 'on',
	}
	
	if isNetOK == true or isNetOK == 1 then
		msg.cmd = 'on'
	else
		msg.cmd = 'off'
	end
	
	MYMQ.publish('control/leds', table2json(msg))
end

function mqtt_callback(topic, msg)
	print(topic, msg)
end

--print(netcheck.isNetOK())
print(isNetOK())

function mqttCallback(topic, msg)

end
-- mqtt start
MYMQ.start('127.0.0.1', 1993, nil, mqttCallback)
MYMQ.connect()
--MYMQ.subscribe({common_topic, common_topic2, key_topic})

log.info('**** net check power on ****')

local count = 1

while true do
	socket.sleep(5)
	MYMQ.handler()
	count = count + 1
	if count >= 12 then
		count = 1
		g_gwip = get_gateway()
		--if g_gwip ~= nil then
			--netcheck.setCheckIP(g_gwip)
		--end
		collectgarbage("collect") -- free mem
	end
	
	--local check = netcheck.isNetOK()
	local check = isNetOK()
	--print(check)
	
	if g_isNetOK == nil then
		log.info('is net ok -> ' .. tostring(check))
		g_isNetOK = check
		ledNotify(check)
	else
		if g_isNetOK ~= check then
			log.info('is net ok -> ' .. tostring(check))
			g_isNetOK = check
			ledNotify(check)
		end
	end
end

