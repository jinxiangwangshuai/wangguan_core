
local socket = require "socket"

local Udp = {}
Udp.__index = Udp


function Udp.new(ip, port, timeout)
	local _ip = ip or nil
	local _port = port or nil
	local _timeout = timeout or 0
    local self = {
		ip = _ip,
		port = _port,
		timeout = _timeout,
		udp_s = socket.udp()
	}
	self.udp_s:settimeout(self.timeout)
    return setmetatable(self, Udp)
end

function Udp:config(ip, port, timeout)
	if ip ~= nil then self.ip = ip end
	if port ~= nil then self.port = port end
	if timeout ~=nil and timeout >= 0 then self.timeout = timeout end
	self.udp_s:settimeout(self.timeout)
end

function Udp:send(msg)
	if msg == nil then print('udp send: cannot send nil message!') return end
	if self.ip == nil then print('udp send: ip cannot be nil!') return end
	if self.port == nil then print('udp send: port cannot be nil!') return end

	self.udp_s:setpeername(self.ip, self.port)
	self.udp_s:send(msg)
end

function Udp:sendto(ip, port, msg)
	if ip ~= nil then self.ip = ip end
	if port ~= nil then self.port = port end

	self:send(msg)
end


return setmetatable({}, {__call = function(_, ...) return Udp.new(...) end})
