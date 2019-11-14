-- this is an app, should be using lua debugger.lua to start
-- 本app主要用于调试和配置，要结合桌面软件StoneDebugger(调试工具)

package.path = package.path .. ";./?.lua"

require "task"
require "common"
require "inilazy"
local socket = require "socket"

local version = 'Hainlin-OneChannel-V1.0.0'
local ini_file = '/home/share/config/config.ini'

local UDP = {
	br_port = 39781,
	r_port = 39782,
}

-- 获取ip地址
while true do
	local ip = get_ip()
	if ip ~= nil and string.len(ip) > 5 then
		UDP.myip = ip
		break
	else
		socket.sleep(1.0)
	end
end

-- 基本配置信息
local config = {
	ip = UDP.myip,
	version = version,
	netmask = get_netmask('eth0'),
	gateway = get_gateway(),
	mac = get_mac(),
	name = get_mac(),
}

-- 处理ini配置文件
if file_exists(ini_file) then
	local ini_table = inilazy.get(ini_file, false)
	if ini_table['config'] ~= nil then
		local name = ini_table['config']['name']
		if name ~= nil then
			config.name = name
		end
	end
else
	-- if not exist, then write an empty file
	local f = assert(io.open(ini_file, "w+"))
	f:write('[config]\n')
	f:write('name='..config.mac..'\n')
	f:close()
end

-- udp相关的初始化
function UDP:init()
	print('init', self.myip, self.br_port)
	
	self.udp_br_r = socket.udp()
	self.udp_br_r:settimeout(3)
	self.udp_br_r:setsockname("*", self.br_port)
	
	self.udp_r = socket.udp()
	self.udp_r:settimeout(0)
	self.udp_r:setsockname(self.myip, self.r_port)
	
	self.udp_s = socket.udp()
	self.udp_s:settimeout(0)
end

-- 接收远端的广播消息
function UDP:broadcast_rev()
	local data, msg_or_ip, port_or_nil = self.udp_br_r:receivefrom()
    if data then
		--print("udp:receivefrom: " .. data .. msg_or_ip, port_or_nil)
		--MASTER:process(data)
		print('broadcast_rev', data)
		UDP:broadcast_process(data)
    elseif msg_or_ip ~= 'timeout' then
		--socket.sleep(0.04)
		print("master udp rev error")
        error("Unknown network error: "..tostring(msg_or_ip))
	else
		--socket.sleep(0.04)
    end
end

function UDP:rev()
	local data, msg_or_ip, port_or_nil = self.udp_r:receivefrom()
    if data then
		--print("udp:receivefrom: " .. data .. msg_or_ip, port_or_nil)
		print('rev', data)
		UDP:rev_process(data)
    elseif msg_or_ip ~= 'timeout' then
		--socket.sleep(0.04)
		print("master udp rev error")
        error("Unknown network error: "..tostring(msg_or_ip))
	else
		--socket.sleep(0.04)
    end
end

function UDP:send(ip, port, message)
	if message == nil or ip == nil or port == nil then return end
	self.udp_s:setpeername(ip, port)
	self.udp_s:send(message)
end

function UDP:broadcast_process(data)
	if data == nil then return end
	local msg = json2table(data)
	if msg == nil then return end
	
	if msg.action == 'broadcast' then
		local resp = {
			action = msg.action..'_resp',
			ip = config.ip,
			port = UDP.r_port,
			version = config.version,
			name = config.name,
			mac = config.mac,
			netmask = config.netmask,
			gateway = config.gateway,
		}
		
		UDP:send(msg.ip, msg.port, table2json(resp))
		resp = nil
	end
end

function UDP:rev_process(data)
	if data == nil then return end
	local msg = json2table(data)
	if msg == nil then return end
	
	if msg.action == 'name_update' then
		local name = msg.name
		local ini_table = inilazy.get(ini_file, false)
		ini_table['config']['name'] = name
		inilazy.set(ini_table, ini_file)
		config.name = name
	elseif msg.action == 'recognize' then
		local rc = task.find('EXTRA_LED')
		print('rc', rc)
		if rc > 0 then
			local led_cmd = {
				led = 'set_led',
				status = 'blink',
				seq = 10, --10hz
				seq_time = 30, --30s
			}
			task.post(rc, table2json(led_cmd), 0)
		end
		local ll = task.list()
		print(table2json(ll))

	elseif msg.action == 'net_config' then
		local ip = msg.set_ip
		local netmask = msg.set_netmask
		local gw = msg.set_gateway
		
		local resp = {
			action = msg.action..'_resp'
		}
		
		if ip == nil or netmask == nil or gw == nil then
			resp.result = 'failed'
			resp.failed = '设置参数不能为空！'
			UDP:send(msg.ip, msg.port, table2json(resp))
			return
		end
		
		resp.result = 'success'
		UDP:send(msg.ip, msg.port, table2json(resp))
		
		local cmd = "nmcli connection modify 'Wired connection 1' connection.autoconnect yes ipv4.method manual ipv4.address "..ip.."/24 ipv4.gateway "..gw.." ipv4.dns "..gw
		os.execute(cmd)
		os.execute('sync')
		os.execute('reboot')
	end
end

-- main process
UDP:init()
local collect_count = 0
while true do
	UDP:broadcast_rev()
	UDP:rev()
	socket.sleep(0.04)
	
	collect_count = collect_count + 1
	if collect_count > 15000 then
		collect_count = 0
		--print('collectgarbage begin', collectgarbage("count"))
		collectgarbage("collect") -- free mem
		--print('collectgarbage end', collectgarbage("count"))
	end
end