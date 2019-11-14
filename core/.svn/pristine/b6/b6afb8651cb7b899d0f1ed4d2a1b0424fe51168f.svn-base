
local socket = require "socket"

local Udp = {}
Udp.__index = Udp

function Udp.new(ip, port, timeout, callback)
	local _ip = ip or nil
	local _port = port or nil
	local _timeout = timeout or 0
	local _callback = callback or nil
    local self = {
		ip = _ip,
		port = _port,
		timeout = _timeout,
		callback = _callback,
		udp_r = socket.udp()
	}
	self.udp_r:settimeout(self.timeout)
	if self.ip ~= nil and self.port ~= nil then
		self.udp_r:setsockname(self.ip, self.port)
	end
    return setmetatable(self, Udp)
end

-- function callback(msg, error)

function Udp:config(ip, port, timeout, callback)
	local is_setting = 0
	if ip ~= nil and ip ~= self.ip then
		self.ip = ip
		is_setting = 1
	end

	if port ~= nil and port ~= self.port then
		self.port = port
		is_setting = 1
	end

	if is_setting > 0 then
		self.udp_r:setsockname(self.ip, self.port)
	end

	if timeout ~=nil and timeout >= 0 and timeout ~= self.timeout then
		self.timeout = timeout
		self.udp_r:settimeout(self.timeout)
	end
end

function Udp:loop()
	local data, msg_or_ip, port_or_nil = self.udp_r:receivefrom()
	
    if data then
		--print("udp:receivefrom: " .. data .. msg_or_ip, port_or_nil)
		if self.callback ~= nil then
			self.callback(data, nil, msg_or_ip, port_or_nil)
		end
    elseif msg_or_ip ~= 'timeout' then
		--socket.sleep(0.04)
		print('udp rev: error ->', msg_or_ip)
		if self.callback ~= nil then
			self.callback(nil, msg_or_ip)
		end
        --error("Unknown network error: "..tostring(msg))
	else
		--socket.sleep(0.04)
    end
end

return setmetatable({}, {__call = function(_, ...) return Udp.new(...) end})
