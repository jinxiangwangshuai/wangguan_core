package.path = package.path .. ";./?.lua;../libs/?.lua;/home/share/core/libs/?.lua;/home/share/core/base/?.lua"
package.cpath = package.cpath..";./?.so;../libc/?.so;/home/share/core/libc/?.so"

require "common"
local linuxWatchdog = require 'linuxWatchdog'

linuxWatchdog.start()
linuxWatchdog.setTimeout(60)

local index = 1
while true do
	linuxWatchdog.feed()
	socket.sleep(2)
	index = index + 1
	if index >= 100 then
		index = 1
		collectgarbage("collect") -- free mem
	end
end

linuxWatchdog.stop()