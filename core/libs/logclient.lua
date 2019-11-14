package.path = package.path .. ";./?.lua;../libs/?.lua;/home/share/core/libs/?.lua"
package.cpath = package.cpath..";./?.so;../libc/?.so;/home/share/core/libc/?.so"

require "common"
local p = require "Print"

local topic = 'log/c/s'

local log = {
	sendFun = nil,
	isEnabled = true,
	isPrint = true,
	from = 'unknown'
}

function log.enable(e)
	if e ~= nil then
		log.isEnabled = e
	end
end

function log.printEnable(e)
	if e ~= nil then
		log.isPrint = e
	end
end

function log.registSendFun(f)
	if f ~= nil and type(f) == 'function' then
		log.sendFun = f
	end
end

function log.setFrom(from)
	log.from = from
end

function log.print(color, ...)
	if log.isPrint == true then
		local args = {...}
		local m = ''
		for k, v in pairs(args) do
			if k == 1 then
				m = v
			else
				m = m .. '  ' .. tostring(v)
			end
		end
		p.print(m, color)
	end
end

function log.debug(m, from)
	if log.isEnabled == true then
		if log.sendFun then
			local msg = {
				action = 'log',
				level = 'debug',
				from = from or log.from,
				content = m,
			}
			log.sendFun(topic, table2json(msg))
		end
	end
	if log.isPrint == true then
		print(m)
	end
end

function log.info(m, from)
	if log.isEnabled == true then
		if log.sendFun then
			local msg = {
				action = 'log',
				level = 'info',
				from = from or log.from,
				content = m,
			}
			log.sendFun(topic, table2json(msg))
		end
	end
	if log.isPrint == true then
		p.print(m, 'blue')
	end
end

function log.warn(m, from)
	if log.isEnabled == true then
		if log.sendFun then
			local msg = {
				action = 'log',
				level = 'warn',
				from = from or log.from,
				content = m,
			}
			log.sendFun(topic, table2json(msg))
		end
	end
	if log.isPrint == true then
		p.print(m, 'yellow')
	end
end

function log.error(m, from)
	if log.isEnabled == true then
		if log.sendFun then
			local msg = {
				action = 'log',
				level = 'error',
				from = from or log.from,
				content = m,
			}
			log.sendFun(topic, table2json(msg))
		end
	end
	if log.isPrint == true then
		p.print(m, 'red')
	end
end

function log.fatal(m, from)
	if log.isEnabled == true then
		if log.sendFun then
			local msg = {
				action = 'log',
				level = 'fatal',
				from = from or log.from,
				content = m,
			}
			log.sendFun(topic, table2json(msg))
		end
	end
	if log.isPrint == true then
		p.print(m, 'red', 'white', 'blink')
	end
end

return log
