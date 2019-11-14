#! /usr/bin/env lua

local _M = {}
_M._M = _M
_M.cols=80

local ex = require("exception")
local class = require("class")

local try = ex.try
local assert = ex.assert
local raise = ex.raise

do
	local line_started = false
	function beginline(str)
		if str and #str > 0
		then str = ("--[%s]--"):format(str)
		else str = ""
		end
		if line_started then
			io.stdout:write(("-"):rep(_M.cols/2))
			print()
		end
		io.stdout:write(str, ("-"):rep(_M.cols/2-#str))
		line_started = true
	end
	function endline(str)
		if str and #str > 0
		then str = ("--[%s]--"):format(str)
		else str = ""
		end
		if not line_started then
			io.stdout:write(("-"):rep(_M.cols/2))
		end
		io.stdout:write(("-"):rep(_M.cols/2-#str), str)
		print()
		line_started = false
	end
	function line(a, b)
		beginline(a)
		endline(b)
	end
end

_M.test = class{
	enabled = true;
	times = 1;
	name = "unnamed";
	break_on_error = false;
	__call = function(self, num)
		if not self.enabled then return self.name, 0, 0, 0 end
		local total, failure, success = 0, 0, 0
		local testname = ("test n°%i (%s)"):format(num, self.name)
		beginline(testname)
		for i = 1, self.times do
			local times_str = ("%i/%i"):format(i, self.times)
			line("running "..testname, times_str)
			total = total + 1
			if try(self[1]) then
				line("success on "..testname.." "..times_str)
				success = success + 1
			else
				line("failure on "..testname.." "..times_str)
				failure = failure + 1
				if self.break_on_error then break end
			end
		end
		line(testname, "statistics")
		print(("%i tests\n\t* %i success (%g%%)\n\t* %i failure (%g%%)"):format(
			total, success, success*100.0/total, failure, failure*100.0/total))
		line()
		return self.name, total, success, failure
	end
}

_M.testtable = class{
	insert = table.insert;
	__call = function(self)
		local total, failure, success = 0, 0, 0
		local ttotal, tcompletefailure, tfailure, tsuccess = 0, 0, 0, 0
		local avg = 0
		for k, v in ipairs(self) do
			local n, t, s, f = self[k](k)
			if t ~= 0 then
				total = total + t
				failure = failure + f
				success = success + s
				ttotal = ttotal + 1
				if f == 0 then
					tsuccess = tsuccess + 1
				elseif s == 0 then
					tcompletefailure = tcompletefailure + 1
				else
					tfailure = tfailure + 1
				end
				avg = avg + (s/t)
			end
		end
		if ttotal <= 1 then return end
		line(nil, "statistics")
		print(("%i tests\n\t* %i success (%g%%)\n\t* %i failure (%g%%)\n\t* %i complete failure (%d%%)\n\t* success average : %d%%"):format(
			ttotal,
			tsuccess, tsuccess*100.0/ttotal,
			tfailure, tfailure*100.0/ttotal,
			tcompletefailure, tcompletefailure*100.0/ttotal,
			avg*100/ttotal))
		print(("total number of tests : %i\n\t* %i success (%g%%)\n\t* %i failure (%g%%)"):format(
			total, success, success*100.0/total, failure, failure*100.0/total))
		line()
	end
}

_M.main = function(all, ...)
	if select('#', ...) > 0 then
		k = tonumber((...))
		all[k]()
	else
		all()
	end
end

return _M
