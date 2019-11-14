
local ll = {}
--[[Whenever Lua sees a \ followed by a decimal number, 
it converts this decimal number into its ASCII equivalent.]]
ll.esc = '\27'

-- Defines the font colors
ll.black 	 	= ll.esc .. '[30m' 
ll.red 	 	 	= ll.esc .. '[31m'
ll.green 	 	= ll.esc .. '[32m'
ll.yellow 	 	= ll.esc .. '[33m'
ll.blue 	 	= ll.esc .. '[34m'
ll.magenta 	 	= ll.esc .. '[35m'
ll.cyan 	 	= ll.esc .. '[36m'
ll.white 	 	= ll.esc .. '[37m'


-- Defines the backgorund colors
ll.bg = {}

ll.bg.black   = ll.esc .. '[40m'
ll.bg.red 	  = ll.esc .. '[41m'
ll.bg.green   = ll.esc .. '[42m'
ll.bg.yellow  = ll.esc .. '[43m'
ll.bg.blue 	  = ll.esc .. '[44m'
ll.bg.magenta = ll.esc .. '[45m'
ll.bg.cyan 	  = ll.esc .. '[46m'
ll.bg.white   = ll.esc .. '[47m'

-- Other attributes
ll.bold		  	= ll.esc .. '[1m'
ll.underline	= ll.esc .. '[4m'
ll.blink		= ll.esc .. '[5m'
ll.inverse		= ll.esc .. '[7m'
ll.strikeout    = ll.esc .. '[8m'
ll.off		    = ll.esc .. '[0m'

ll.endl			= ll.esc .. '[0m\n'

ll.important = ll.esc .. '[1;44;37m'
ll.error    = ll.esc .. '[1;5;41;37m'

function ll.print(m, color, bg, attr)
	local s = ll.off
	if ll[color] ~= nil then
		s = s..ll[color]
	end
	if ll.bg[bg] ~= nil then
		s = s..ll.bg[bg]
	end
	if ll[attr] ~= nil then
		s = s..ll[attr]
	end
	s = s..m..ll.off
	print(s)
end

return ll