package.path = package.path .. ";./?.lua;../libs/?.lua;/home/share/core/libs/?.lua;/home/share/core/base/?.lua"
package.cpath = package.cpath..";./?.so;../libc/?.so;/home/share/core/libc/?.so"

require "common"
require "mymqtt"
require "base_db"
require "version"

local json = require('cjson')
local socket = require "socket"
local http=require("socket.http")
local ltn12 = require "ltn12"
log = require "logclient"

local UdpR = require("udpr")
local UdpS = require('udps')

local udps = UdpS()

local Timer = require 'Timer'
local timer = Timer()

require "base_main.inside_heartbeat"

IHB.setEnabled(false)

log.enable(true)
log.printEnable(false)
log.setFrom('base_main')
log.registSendFun(function(topic, m)
		MYMQ.publish(topic, m)
	end
)

-- global variabel
local broadcast_port = 39781
local myip = nil

-- wait to get ip
while true do
	local ip = get_ip()
	if ip == nil then
		print('cannot get current ip')
		socket.sleep(1)
	else
		myip = ip
		print('current ip', myip)
		break
	end
end

-- 设置默认的upgrade url
basedb.set_data({upgrade_url = 'http://'..myip..'/upgrade'})

local mac = get_mac()
local netmask = get_netmask('eth0')
local gateway = get_gateway()
local dns1 = get_dns(1)
local dns2 = get_dns(2)
local common_topic = mac .. '/common'
local common_topic2 = 'gw/common'
local key_topic = 'notify/key'
local inside_heartbeat_topic = 'inside/heartbeat'

local function stringSplit( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

local function getPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    
    n = n or 0;
    n = math.floor(n)
    local fmt = '%.' .. n .. 'f'
    local nRet = tonumber(string.format(fmt, nNum))

    return nRet;
end

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

function getMemRate()
	local cmd = 'cat /proc/meminfo | grep MemTotal | cut -d ":" -f 2 | sed s/[[:space:]]//g | sed "s/kB//g"'
	local total = readShell(cmd)
	
	cmd = 'cat /proc/meminfo | grep MemFree | cut -d ":" -f 2 | sed s/[[:space:]]//g | sed "s/kB//g"'
	local free = readShell(cmd)
	
	total = tonumber(total)
	free = tonumber(free)
	if total == 0 or total == nil then return 0 end
	local result = (total - free) / total
	result = result * 100
	result = getPreciseDecimal(result, 1)
	result = result*10
	return result
end

function getCpuRate()
--[[
	local cmd = 'top -n2 | grep Cpu | tail -1 | cut -d " " -f 2'
	local data = readShell(cmd)
	if data == nil then return 0 end
	local rate = tonumber(data)
	rate = rate * 10
	if rate == nil then return 0 end
	return rate
--]]
	local cmd = 'bash /home/share/core/base/cpu_rate.sh'
	local result = readShell(cmd)
	if result == nil then return nil end
	return tonumber(result)*10
end

function cputemp()
	local cmd = 'cpu_freq | grep CPU0 | cut -d " " -f 3 | cut -d "=" -f 2'
	local result = readShell(cmd)
	if string.len(result) > 0 then
		-- 如果最后一个字符不是数字，则去掉
		local tail = string.byte(result, -1)
		if (not (tail >= 48 and tail <= 57)) then
			result = string.sub(result, 1, -2)
		end
	end
	--print('cpu temperature', result)
	if result == nil then return nil end
	return tonumber(result)
end

function broadcast_rev(msg, err, ip, port)
	if msg == nil then return end
	--print('broadcast rev', msg)
	msg = json2table(msg)
	if msg.action == 'broadcast' then
		local ip = msg.ip
		local port = msg.port
		if ip == nil or port == nil then return end

		-- some data shold be from DB
		-- get param from DB
		local dbdata = basedb.get_data()
		local myname = dbdata.name or 'defaultname'

		local resp = {
			action = msg.action .. '_resp',
			ip = myip,
			mac = mac,
			name = myname,
			version = g_version,
			netmask = netmask,
			gateway = gateway,
			upgrade_url = dbdata.upgrade_url,
			protocol = 'mqtt',
			port = 1993,
			platform = dbdata.platform or 'neo-core-01',
			model = dbdata.model or 'common-gw'
		}
		
		if dbdata.dns1 ~= nil then
			resp.dns1 = dbdata.dns1
		end
		
		if dbdata.dns2 ~= nil then
			resp.dns2 = dbdata.dns2
		end
		
		local webconfig = basedb.get_webconfig_data()
		resp.webconfig = webconfig
		udps:sendto(ip, port, table2json(resp))
	end
end

local udpr = UdpR('*', broadcast_port, 0, broadcast_rev) -- * is to rev broadcast msg

function mqtt_callback(topic, msg)
	if msg == nil then return end
	--print('mqtt rev', msg)
	msg = json2table(msg)
	if msg == nil then return end

	if topic == inside_heartbeat_topic then
		IHB.msgProcess(msg)
	elseif topic == common_topic or topic == common_topic2 then
		common_topic_process(msg)
	elseif topic == key_topic then
		key_topic_process(msg)
	end
end

function key_topic_process(msg)
	if msg.action == 'system_key' and msg.status == 'long_10s' then
		-- reset to factory
		-- start net transfer led mode
		local led_mode_reset_factory = {action='mode_start', cmd='reset_factory'}
		MYMQ.publish('control/leds', table2json(led_mode_reset_factory))
		socket.sleep(2) -- give led enough time to blink
		-- get from DB
		local data = basedb.get_data()
		local ip = data.default_ip
		local netmask = data.default_netmask
		local gw = data.default_gateway
		local cmd = "nmcli connection modify 'Wired connection 1' connection.autoconnect yes ipv4.method manual ipv4.address "..ip.."/24 ipv4.gateway "..gw.." ipv4.dns "..gw
		log.info(cmd)
		os.execute(cmd)
		cmd = "nmcli connection modify 'Wired connection 1' +ipv4.dns 114.114.114.114"
		log.info(cmd)
		log.info('config network -> reboot')
		os.execute('sync')
		os.execute('reboot')
	end
end

function common_topic_process(msg)
	if msg.action == 'network_config' then
		local ip = msg.ip
		local netmask = msg.netmask
		local gw = msg.gateway

		if ip == nil or netmask == nil or gw == nil then
			print('network param cannot be nil')
			return
		end
		
		local dns1 = gw
		local data = {
			dns1 = dns1
		}
		if msg.dns1 ~= nil then
			data.dns1 = msg.dns1
			dns1 = msg.dns1
		end
		if msg.dns2 ~= nil then
			data.dns2 = msg.dns2
		end
		basedb.set_data(data)
		socket.sleep(1)
		
		local resp = {
			action = msg.action..'_resp',
			result = 'success',
		}
		MYMQ.publish('tool/notify', table2json(resp))

		-- only OK in nanopi core
		local cmd = "nmcli connection modify 'Wired connection 1' connection.autoconnect yes ipv4.method manual ipv4.address "..ip.."/24 ipv4.gateway "..gw.." ipv4.dns "..dns1
		log.info(cmd)
		os.execute(cmd)
		if msg.dns2 == nil then
			if dns2 ~= nil then
				cmd = 'nmcli con mod "Wired connection 1" -ipv4.dns ' .. dns2
				log.info(cmd)
				os.execute(cmd)
			end
		else
			if dns2 == nil then
				cmd = 'nmcli con mod "Wired connection 1" +ipv4.dns ' .. msg.dns2
				log.info(cmd)
				os.execute(cmd)
			else
				if msg.dns2 ~= dns2 then
					cmd = 'nmcli con mod "Wired connection 1" -ipv4.dns ' .. dns2
					log.info(cmd)
					os.execute(cmd)
					cmd = 'nmcli con mod "Wired connection 1" +ipv4.dns ' .. msg.dns2
					log.info(cmd)
					os.execute(cmd)
				end
			end
		end 
		log.info('config network -> reboot')
		os.execute('sync')
		os.execute('reboot')
	elseif msg.action == 'set_name' then
		if msg.name == nil or type(msg.name) ~= 'string' then return end
		local myname = msg.name

		-- save name to DB
		basedb.set_name(myname)

		local resp = {
			action = 'name_notify',
			mac = mac,
			name = myname,
		}
		MYMQ.publish('tool/notify', table2json(resp))
	elseif msg.action == 'get_baseinfo' then
		local resp = basedb.get_data()
		resp.action = 'baseinfo_notify'
		resp.mac = mac
		resp.ip = myip
		resp.netmask = netmask
		resp.gateway = gateway
		resp.dns1 = dns1 or gateway
		if dns2 then
			resp.dns2 = dns2
		end
		MYMQ.publish('tool/notify', table2json(resp))
	elseif msg.action == 'get_baseinfo_all' then
		local resp = basedb.get_data()
		resp.action = 'baseinfo_all_notify'
		resp.mac = mac
		resp.ip = myip
		resp.netmask = netmask
		resp.gateway = gateway
		resp.dns1 = dns1 or gateway
		if dns2 then
			resp.dns2 = dns2
		end
		resp.cpu = getCpuRate()
		resp.mem = getMemRate()
		resp.temp = cputemp()
		resp.webconfig = basedb.get_webconfig_data()
		resp.version = g_version
		MYMQ.publish('tool/notify', table2json(resp))
	elseif msg.action == 'get_webconfiginfo' then
		local resp = basedb.get_webconfig_data()
		resp.action = 'webconfiginfo_notify'
		MYMQ.publish('tool/notify', table2json(resp))
	elseif msg.action == 'set_baseinfo' then
		msg.action = nil
		basedb.set_data(msg)
		local resp = basedb.get_data()
		resp.action = 'baseinfo_notify'
		resp.mac = mac
		resp.ip = myip
		MYMQ.publish('tool/notify', table2json(resp))
	elseif msg.action == 'set_webconfiginfo' then
		msg.action = nil
		basedb.set_webconfig(msg)
		local resp = basedb.get_webconfig_data()
		resp.action = 'webconfiginfo_notify'
		MYMQ.publish('tool/notify', table2json(resp))
	elseif msg.action == 'get_status' then
		-- get from DB
		local data = basedb.get_data()
		local status = data.status or 'db missing'
		
		local resp = {
			action = 'status_notify',
			mac = mac,
			status = status,
		}
		MYMQ.publish('tool/common', table2json(resp))
	elseif msg.action == 'recognize' then
		local cmd = msg.cmd
		if cmd == 'start' then
			local led = {
				action = 'set',
				cmd = 'blink',
				freq = 4,
				freq_time = 30,
			}
			print(table2json(led))
			MYMQ.publish('control/leds', table2json(led))
		elseif cmd == 'stop' then
				local led = {
				action = 'set',
				cmd = 'off',
			}
			print(table2json(led))
			MYMQ.publish('control/leds', table2json(led))
		end
	elseif msg.action == 'shell' then
		local cmd = msg.cmd
		os.execute(cmd)
	end
end

-- mqtt start
MYMQ.start('127.0.0.1', 1993, nil, mqtt_callback)
MYMQ.connect()
MYMQ.subscribe({common_topic, common_topic2, key_topic, inside_heartbeat_topic})

-- start timer
function garbage_timer()
	--print('collectgarbage begin', collectgarbage("count"))
	collectgarbage("collect") -- free mem
	--print('collectgarbage end', collectgarbage("count"))
end
local garbage_timer_handler = timer:every(20000, garbage_timer, -1)

-- start net transfer led mode
local led_mode_transfer = {action='mode_start', cmd='transfer'}
MYMQ.publish('control/leds', table2json(led_mode_transfer))

log.info('**** base_main power on ****')

while true do
	socket.sleep(0.01)
	udpr:loop()
	MYMQ.handler()
	timer:update(10) -- 10ms
	IHB.loop(10)
end
