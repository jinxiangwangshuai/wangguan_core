local mqtt = require "paho.mqtt"
require "socket"

--mqtt.Utility.set_debug(true)

-- check connect status timer
local mqtt_Timer = require 'Timer'
local mqtt_timer = mqtt_Timer()

local function random_client_id()
	math.randomseed(tostring(socket.gettime()):reverse():sub(1, 6))
	local res = math.random(10000,1000000)
	res = 'client'..tostring(res)
	return res
end

MYMQ = MYMQ or {
	is_init = false,
	mqtt = mqtt,
	mqtt_client = nil,
	callback = nil,
	addr = nil,
	port = nil,
	client_id = nil,
	name = nil,
	password = nil,
	topics = nil,
	error_message = nil,
	timer_handler = nil
}

local function dummy_cb(topic, msg)
	print('dummy callback', topic, msg)
end

function MYMQ.set_callback(cb)
	if type(cb) == 'function' then
		MYMQ.callback = cb
	end
end

function MYMQ.auth(name, password)
	MYMQ.name = name
	MYMQ.password = password
end

function MYMQ.subscribe(topics)
	if not MYMQ.mqtt_client.connected then print('disconnected, cannot subscribe') return end
	if type(topics) == 'table' then
		MYMQ.topics = topics
	else
		MYMQ.topics = {tostring(topics)}
	end

	if MYMQ.mqtt_client ~= nil then
		MYMQ.mqtt_client:subscribe(MYMQ.topics)
	end
end

function timer_fun()
	if MYMQ.mqtt_client.connected then return end
	print('mqtt timer: disconnected and reconnect')
	MYMQ.reconnect()
end

function MYMQ.start(addr, port, client_id, cb)
	if MYMQ.is_init then return end
	if addr == nil then
		print("address cannot be nil!")
		return
	end
	MYMQ.is_init = true

	MYMQ.addr = addr
	MYMQ.port = port or 1883
	MYMQ.client_id = client_id or random_client_id()
	MYMQ.callback = cb or dummy_cb

	MYMQ.mqtt_client = MYMQ.mqtt.client.create(MYMQ.addr, MYMQ.port, MYMQ.callback)

	if MYMQ.mqtt_client == nil then print('create mqtt client error') end

	if MYMQ.name ~= nil and MYMQ.password ~= nil then
		MYMQ.mqtt.client.auth(MYMQ.mqtt_client, MYMQ.name, MYMQ.password)
	end

	-- start timer
	if MYMQ.timer_handler ~= nil then
		mqtt_timer:cancel(MYMQ.timer_handler)
	end
	MYMQ.timer_handler = mqtt_timer:every(5000, timer_fun, -1) -- 5s
end

function MYMQ.connect()
	if MYMQ.mqtt_client.connected then return end

	MYMQ.mqtt_client:connect(MYMQ.client_id)
	if MYMQ.topics ~= nil then
		MYMQ.mqtt_client:subscribe(MYMQ.topics)
	end
end

function MYMQ.reconnect()
	if MYMQ.mqtt_client.connected then return end
	if MYMQ.mqtt_client == nil then
		MYMQ.start(MYMQ.addr, MYMQ.port, MYMQ.client_id, MYMQ.callback)
	end
	MYMQ.connect()
end

function MYMQ.publish(topic, msg)
	if topic == nil then print('topic cannot be nil!') return end
	if msg == nil then print('messag cannot be nil!') return end
	if not MYMQ.mqtt_client.connected then print('disconnected, cannot publish') return end

	MYMQ.mqtt_client:publish(topic, msg)
end

function MYMQ.connected()
	if MYMQ.mqtt_client == nil then return false end
	return MYMQ.mqtt_client.connected
end

function MYMQ.uninit()
	if MYMQ.timer_handler ~= nil then
		mqtt_timer:cancel(MYMQ.timer_handler)
	end
	if MYMQ.topics ~= nil then
		MYMQ.mqtt_client:unsubscribe(MYMQ.topics)
	end
	MYMQ.mqtt_client:destroy()
	MYMQ.mqtt_client = nil
end

-- must be in main loop
function MYMQ.handler()
	mqtt_timer:update(1) -- 1ms

	if not MYMQ.mqtt_client.connected then
		return 'mqtt disconnected'
	end
	MYMQ.error_message = MYMQ.mqtt_client:handler()
	return MYMQ.error_message
end

-- test
--[[
--MYMQ.start('genie.stone-dl.com', 1993, random_client_id())
MYMQ.start("127.0.0.1", 1993, random_client_id())
MYMQ.connect()
MYMQ.subscribe({'test1', 'test2'})

while true do
	print('result', MYMQ.handler())
	socket.sleep(0.001)
end

MYMQ.uninit()
--]]




