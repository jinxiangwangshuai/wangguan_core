package.path = package.path .. ";./?.lua;../libs/?.lua;/home/share/core/libs/?.lua;/home/share/core/?.lua;/home/share/core/common_gw/?.lua"
package.cpath = package.cpath..";./?.so;../libc/?.so;/home/share/core/libc/?.so"

require "mymqtt"
require "common"
local log = require "logclient"
local socket = require "socket"

log.enable(true)
log.printEnable(false)
log.setFrom('system')
log.registSendFun(function(topic, m)
		MYMQ.publish(topic, m)
	end
)

function read_shell(cmd)
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

-- collectgarbage
function luafree()
	collectgarbage("collect")
end

-- free buff/caches
function free_caches()
	os.execute('sync')
	os.execute('echo 1 > /proc/sys/vm/drop_caches')
	os.execute('echo 2 > /proc/sys/vm/drop_caches')
	os.execute('echo 3 > /proc/sys/vm/drop_caches')
end

function cpuinfo()
	local cmd = 'bash /home/share/core/base/cpu_rate.sh'
	local result = read_shell(cmd)
	log.print('yellow', 'cpu rate user', result)
	-- print('cpu rate user', result)
	if result == nil then return nil end
	return tonumber(result)
end

function meminfo()
	local cmd = 'cat /proc/meminfo | grep MemFree | cut -d ":" -f 2 | sed s/[[:space:]]//g | sed "s/kB//g"'
	local result = read_shell(cmd)
	log.print('yellow', 'mem free kB', result)
	--print('mem free kB', result)
	if result == nil then return nil end
	return tonumber(result)
end

-- ����Ӳ�����������/dev/mmcblk0p
function diskinfo()
	local cmd = "df -h | grep '/dev/mmcblk0p2' | awk -F '[ %]+' '{print $5}'"
	local result = read_shell(cmd)
	if result == nil then
		cmd = "df -h | grep 'overlay' | awk -F '[ %]+' '{print $5}'"
		result = read_shell(cmd)
	end
	log.print('yellow', 'disk %', result)
	--print('disk %', result)
	if result == nil then return nil end
	return tonumber(result)
end

-- ����nanopi coreƽ̨
function cputemp()
	local cmd = 'cpu_freq | grep CPU0 | cut -d " " -f 3 | cut -d "=" -f 2'
	local result = read_shell(cmd)
	if string.len(result) > 0 then
		-- 如果最后一个字符不是数字，则去掉
		local tail = string.byte(result, -1)
		if (not (tail >= 48 and tail <= 57)) then
			result = string.sub(result, 1, -2)
		end
	end
	log.print('yellow', 'cpu temperature', result)
	--print('cpu temperature', result)
	if result == nil then return nil end
	return tonumber(result)
end

function restart(log)
	log.print('red', log)
	--print(log)
	log.warn('!! reboot !!')
	os.execute('sleep 3')
	os.execute('sync')
	os.execute('reboot')
	--os.exit()
end

-- ÿ10���ӣ�����һ������
local garbage_count = 0
function check_luafree()
	garbage_count = garbage_count + 1
	if garbage_count > 600 then
		garbage_count = 0
		log.print('green', '--collect garbage')
		--print('--collect garbage')
		luafree()
	end
end

-- ÿ1���ӣ��ͷ�һ�λ���
local caches_count = 0
function check_free_caches()
	caches_count = caches_count + 1
	if caches_count > 50 then
		caches_count = 0
		log.print('green', '-- free caches')
		--print('-- free caches')
		free_caches()
	end
end

-- �������15���ӣ�cpu ���� 60%����������������100%������ϵͳ
local cpuinfo_count = 0
function check_cpuinfo()
	local result = cpuinfo() -- ����ֵΪ�ٷֱ�num
	if result == nil then return end
	--log.info('cpu rate -> ' .. result .. '%')
	if result > 60 then
		cpuinfo_count = cpuinfo_count + 1
		if cpuinfo_count > 900 then
			cpuinfo_count = 0
			log.info('cpu rate -> ' .. result .. '%')
			log.warn('cpu > 60% more than 15 minutes, restart!')
			restart('cpu > 60% more than 15 minutes, restart!')
		end
	else
		cpuinfo_count = 0
	end
end

-- ��� �ڴ�����10�Σ�free ����2M������
local meminfo_count = 0
function check_meminfo()
	local result = meminfo()
	if result == nil then return end
	--log.info('mem free -> ' .. result .. 'kB')
	if result < 20480 then
		free_caches()
		meminfo_count = meminfo_count + 1
		if meminfo_count > 10 then 
			meminfo_count = 0
			log.info('mem free -> ' .. result .. 'kB')
			log.warn('mem < 20M more than 10 second, restart!')
			restart('mem < 20M more than 10 second, restart!')
		end
	else
		meminfo_count = 0
	end
end

-- ��� �ڴ�����10�Σ�disk ����90%�����log������
local diskinfo_count = 0
function check_diskinfo()
	local result = diskinfo()
	if result == nil then return end
	--log.info('disk info -> ' .. result .. '%')
	if result > 92 then
		diskinfo_count = diskinfo_count + 1
		if diskinfo_count > 10 then 
			diskinfo_count = 0
			os.execute('rm -f /home/share/log/*')
			os.execute('rm -f /home/share/core/webconfig/log/*')
			log.info('disk info -> ' .. result .. '%')
			log.warn('disk > 92% more than 10 second, delete all log and restart!')
			restart('disk > 92% more than 10 second, delete all log and restart!')
		end
	else
		diskinfo_count = 0
	end
end

-- ���������Сʱ���¶ȳ���80�ȣ�����
local cputemp_count = 0
function check_cputemp()
	local result = cputemp()
	if result == nil then return end
	--log.info('cpu temperature -> ' .. result)
	if result > 80000 then
		cputemp_count = cputemp_count + 1
		if cputemp_count > 900 then 
			cputemp_count = 0
			log.info('cpu temperature -> ' .. result)
			log.warn('cpu temperature > 75 more than 0.5 hour, restart!')
			restart('cpu temperature > 75 more than 0.5 hour, restart!')
		end
	else
		if result > 50000 then
			log.info('! cpu temperature -> ' .. result)
		elseif result > 60000 then
			log.warn('!!! cpu temperature -> ' .. result)
		end
		cputemp_count = 0
	end
end

local function isSystemReadonly()
	local cmd = "mount | grep /dev/mmcblk0p2"
	
	local resp = read_shell(cmd)
	if resp ~= nil then
		local find = string.find(resp, "ro")
		if find == nil then 
			return false
		else
			return true
		end
	end
	return false
end

local readonly_count = 0
function check_system_readonly()
-- 仅老版本适用
	readonly_count = readonly_count + 1
	if readonly_count > 10 then 
		readonly_count = 0
		local resp = isSystemReadonly()
		if resp == true then
			restart('system readonly, restart!')
		end
	end
end

local function checkBuffCachedMem()
	local cmd = "free -m | grep Mem | tr -s ' ' | cut -d ' ' -f 6"
	local result = read_shell(cmd)
	if result == nil then return end
	result = tonumber(result)
	if result ~= nil and result > 110 then
		free_caches()
	end
end

function mqttCallback(topic, msg)

end

local function insideHeartbeat()
	local msg = {
		action = 'heartbeat',
	}

	MYMQ.publish('inside/heartbeat', table2json(msg))
end
 
-- mqtt start
MYMQ.start('127.0.0.1', 1993, nil, mqttCallback)
MYMQ.connect()

log.info('**** system lua power on ****')

-- free at power on
free_caches()

while true do
	log.print('yellow', '\n')
	socket.sleep(1)
	insideHeartbeat()
	checkBuffCachedMem()
	check_luafree()
	check_free_caches()
	--check_cpuinfo()
	--check_meminfo()
	--check_cputemp()
	--check_diskinfo()
	--check_system_readonly()
	
	MYMQ.handler()
end

