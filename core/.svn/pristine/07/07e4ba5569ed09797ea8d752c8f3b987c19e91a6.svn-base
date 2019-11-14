
package.path = package.path .. ";./?.lua;../libs/?.lua;/home/share/core/libs/?.lua;/home/share/core/base/?.lua;/home/share/core/?.lua"
package.cpath = package.cpath..";./?.so;../libc/?.so;/home/share/core/libc/?.so"

require "lfs"
require "common"
require "inilazy"
require "logging.file"
require "mymqtt"
require "rpcs"
local Timer = require 'Timer'
local timer = Timer()
local socket = require "socket"

local logFilePath = "/home/share/core/webconfig/log/system.log"
local logger = logging.file(logFilePath, "%Y") -- logger is the global
--logger:info("[test] this is a test log")

local p = require "Print"
--[[
p.print('hello world')
p.print('hello world', 'green')
p.print('hello world', 'yellow', 'blue')
p.print('hello world', 'black', 'white', 'blink')
--]]

local logEnabled = true
local logLevel = 5 -- 如果只记录error和fatal，那么就是2
local idleCount = 1000 -- 当一定时间内没有log到来时，则让系统休息时间长一点，这样少占用cpu
local logTopic = 'log/c/s'

local myip = nil
-- wait to get ip
while true do
	local ip = get_ip()
	if ip == nil then
		print('cannot get current ip')
		socket.sleep(1)
	else
		myip = ip
		print('current ip', ip)
		break
	end
end

local function checkdir(path)
	local resp = {}
	for file in lfs.dir(path) do
		if file ~= '.' and file ~= '..' then
			local f = 'http://'..myip..'/log/'..file
			table.insert(resp, {file = file, path = f})
		end
	end
	return resp
end

--checkdir('/home/share/core/webconfig/log')

function RPCS.getLogList(params)
	local resp = checkdir('/home/share/core/webconfig/log')
	return 'success', nil, resp
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

local function mqttCallback(topic, msg)
	--print(topic, msg)
	if msg == nil then return end
	--p.print('mqtt rev ' .. msg, 'red')

	if topic == "c/s/rpc" then
		RPCS.process(msg)
	elseif topic == logTopic then
		msg = json2table(msg)
		if msg == nil then return end
		if msg.action == 'log' then
			idleCount = 1000 -- reset idle count
			local level = msg.level
			local from = 'unknown'
			if msg.from ~= nil then
				from = msg.from
			end
			local content = '<' .. from .. '> ' .. msg.content
			if level == 'debug' and logLevel >= 1 then
				logger:debug(content)
			elseif level == 'info' and logLevel >= 2 then
				logger:info(content)
			elseif level == 'warn' and logLevel >= 3 then
				logger:warn(content)
			elseif level == 'error' and logLevel >= 4 then
				logger:error(content)
			elseif level == 'fatal' and logLevel >= 5 then
				logger:fatal(content)
			end
		end
	end
end

-- 执行logrotate对日志文件进行转存
local function logrotate_timer()
	--print('logrotate_timer')
	local cmd = '/usr/sbin/logrotate /etc/logrotate.d/logrotate_ctl'
	readShell(cmd)
end

-- start timer
local function garbage_timer()
	--print('collectgarbage begin', collectgarbage("count"))
	collectgarbage("collect") -- free mem
	--print('collectgarbage end', collectgarbage("count"))
end
local garbage_timer_handler = timer:every(20000, garbage_timer, -1)
local logrotate_timer_handler = timer:every(60000, logrotate_timer, -1)

-- mqtt start
MYMQ.start('127.0.0.1', 1993, nil, mqttCallback)
MYMQ.connect()
MYMQ.subscribe({logTopic, "c/s/rpc"})

function rpcResponse(msg)
	if msg then
		MYMQ.publish('s/c/rpc', msg)
	end
end

function rpcNotify(msg)
	if msg then
		MYMQ.publish('s/c/notify', msg)
	end
end

RPCS.register({responseFun = rpcResponse, notifyFun = rpcNotify})
RPCS.filterConfig('log')

logger:debug('**************** logserver power on *****************')

while true do
	if idleCount > 0 then idleCount = idleCount - 1 else idleCount = 0 end
	if logEnabled == true then
		if idleCount == 0 then
			socket.sleep(0.05)
			timer:update(50) -- 50ms
		else
			socket.sleep(0.002)
			timer:update(2) -- 2ms
		end
	else
		socket.sleep(0.1)
		timer:update(100) -- 100ms
	end
	MYMQ.handler()
end
