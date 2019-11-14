local json = require('cjson')
local socket = require "socket"
local http=require("socket.http")
local ltn12 = require "ltn12"
local crc = require "ul_crc"

function arr(data, index)
	local charcode = string.byte(data, index, index)
	if charcode == nil then return nil end
	charcode = tonumber(charcode);
	--local charcode = string.byte(data, index, index);
	return charcode
end

function hex2str(hex)
 if type(hex) == 'string' and string.len(hex) == 1 then
 	return string.format("%02X", string.byte(hex,1,1))
 end
 
 local str = "";
 for i = 1, string.len(hex) do
     local charcode = tonumber(string.byte(hex, i, i));
     str = str .. string.format("%02X", charcode);
 end
 return str;
end

function str2hex(str)
 if string.len(str) == 2 then
 	local n = tonumber(str, 16)
 	if 0 == n then
       return '\00';
    else
       return string.format("%c", n);
    end
 end
 
 local hex = "";
 for i = 1, string.len(str) - 1, 2 do
     local doublebytestr = string.sub(str, i, i+1);
     local n = tonumber(doublebytestr, 16);
     if 0 == n then
       hex = hex .. '\00';
     else
       hex = hex .. string.format("%c", n);
     end
 end
 return hex;
end

function num2hex(num)
	local tmp = num2hexstr(num)
	return str2hex(tmp)
end

function bin2hex(s)
    s=string.gsub(s,"(.)",function (x) return string.format("%02X ",string.byte(x)) end)
    return s
end

function num2hexstr(num)
	local ret = 0
	if type(num) == 'string' then
		ret = string.format("%02X", string.byte(num, 1, 1))
	else
		ret = string.format("%02X", tonumber(num, 10))
	end
	if string.len(ret) == 1 or string.len(ret) == 3 or string.len(ret) == 5 or string.len(ret) == 7 then
		ret = '0'..ret
	end
	return ret
end

--[[
local h2b = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["A"] = 10,
    ["B"] = 11,
    ["C"] = 12,
    ["D"] = 13,
    ["E"] = 14,
    ["F"] = 15
}
--]]
local h2b = {
    ["0"] = '0000',
    ["1"] = '0001',
    ["2"] = '0010',
    ["3"] = '0011',
    ["4"] = '0100',
    ["5"] = '0101',
    ["6"] = '0110',
    ["7"] = '0111',
    ["8"] = '1000',
    ["9"] = '1001',
    ["A"] = '1010',
    ["B"] = '1011',
    ["C"] = '1100',
    ["D"] = '1101',
    ["E"] = '1110',
    ["F"] = '1111',
    ["a"] = '1010',
    ["b"] = '1011',
    ["c"] = '1100',
    ["d"] = '1101',
    ["e"] = '1110',
    ["f"] = '1111',
}

function hex2bin( hexstr )
	local ret = nil
	for i = 1, string.len(hexstr), 1 do
		local temp = string.sub(hexstr, i, i)
		if ret == nil then
			ret = h2b[temp]
		else
			ret = ret..h2b[temp]
		end
	end
    return ret
end  

------ json
function table2json(t)
	return json.encode(t)
end

function json2table(j)
	return json.decode(j)
end

-- 传入true，则空table转成{}
-- 传入false， 则空table转成[]
function jsonNullTableAsObject(flag)
	json.encode_empty_table_as_object(flag) 
end

---
-- @function: ��ӡtable�����ݣ��ݹ�
-- @param: tbl Ҫ��ӡ��table
-- @param: level �ݹ�Ĳ�����Ĭ�ϲ��ô�ֵ����
-- @param: filteDefault �Ƿ���˴�ӡ���캯����Ĭ��Ϊ��
-- @return: return
function print_table( tbl , level, filteDefault)
  local msg = ""
  filteDefault = filteDefault or true --Ĭ�Ϲ��˹ؼ��֣�DeleteMe, _class_type��
  level = level or 1
  local indent_str = ""
  for i = 1, level do
    indent_str = indent_str.."  "
  end

  print(indent_str .. "{")
  for k,v in pairs(tbl) do
    if filteDefault then
      if k ~= "_class_type" and k ~= "DeleteMe" then
        local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
        print(item_str)
        if type(v) == "table" then
          print_table(v, level + 1)
        end
      end
    else
      local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
      print(item_str)
      if type(v) == "table" then
        print_table(v, level + 1)
      end
    end
  end
  print(indent_str .. "}")
end

function deep_copy( obj )
    local InTable = {};
    local function Func(obj)
        if type(obj) ~= "table" then   --�жϱ����Ƿ��б�
            return obj;
        end
        local NewTable = {};  --����һ���±�
        InTable[obj] = NewTable;  --�������б����Ȱѱ��InTable������NewTableȥ������Ƕ�ı�
        for k,v in pairs(obj) do  --�Ѿɱ��key��Value�����±�
            NewTable[Func(k)] = Func(v);
        end
        return setmetatable(NewTable, getmetatable(obj))--��ֵԪ��
    end
    return Func(obj) --�������б������Ƕ�ı�Ҳ������
end

-- get ip
function get_ip()
--[[
	local hostname = socket.dns.gethostname()

	print("hostname -> " .. hostname)
    local ip, resolved = socket.dns.toip(hostname)
    local ListTab = {}

    for k, v in ipairs(resolved.ip) do
        table.insert(ListTab, v)
    end

	--if _VERSION == "Lua 5.1" then
	--	return unpack(ListTab)
	--else
	--	return table.unpack(ListTab)
	--end

	local ret = ""
	for k, v in pairs(ListTab) do
		ret = ret .. v .. " "
	end
	return ret
	--]]

	local cmd = "ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\\/(.*)/, \"\\\\1\", \"g\", $2)}'"
	local t = io.popen(cmd)
	if t == nil then return nil end
	local content = t:read("*a")
	t:close()
	-- remove "\r\n"
	content = string.gsub(content,"\r","")
    content = string.gsub(content,"\n","")
	return content
end

-- get mac
function get_mac()

	local cmd = "ifconfig | grep HW | awk '{printf $5}'"
	local t = io.popen(cmd)
	if t == nil then return nil end
	local content = t:read("*a")
	t:close()
	-- remove "\r\n"
	content = string.gsub(content,"\r","")
    content = string.gsub(content,"\n","")
	return content
end

-- get netmask ip address
function get_netmask(eth) -- eth is eth0 or other
	local cmd = "ifconfig "..eth.." | grep Mask | awk '{printf $4}' | sed 's/Mask://g'"
	local t = io.popen(cmd)
	if t == nil then return nil end
	local content = t:read("*a")
	t:close()
	-- remove "\r\n"
	content = string.gsub(content,"\r","")
    content = string.gsub(content,"\n","")
	return content
end

-- get gateway ip address
function get_gateway()
	local cmd = "route -n | grep UG | tr -s [:space:] | cut -d ' ' -f 2"
	--"netstat -r | grep default | awk '{printf $2}'";
	local t = io.popen(cmd)
	if t == nil then return nil end
	local content = t:read("*a")
	t:close()
	-- remove "\r\n"
	content = string.gsub(content,"\r","")
    content = string.gsub(content,"\n","")
	return content
end

-- 获取dns地址，仅限于nmcli工具下的。参数为数字
function get_dns(index)
	local cmd = 'nmcli dev show | grep IP4.DNS[[]' .. tostring(index) .. '[]] | sed s/[[:space:]]//g | cut -d ":" -f 2'
	local t = io.popen(cmd)
	if t == nil then return nil end
	local content = t:read("*a")
	t:close()
	-- remove "\r\n"
	content = string.gsub(content,"\r","")
    content = string.gsub(content,"\n","")
	return content
end

------------- http post --------------
function post(url, content)
	local request_body= nil
	----[[
	if type(content) ~= "table" then
		request_body = content
	else
		request_body = "luajson=" .. table2json(content)
	end
	--]]

	local response_body = {}
	local res, code, response_headers = http.request{
      url = url,
      method = "POST",
      headers =
        {
            ["Content-Type"] = "application/x-www-form-urlencoded";
            ["Content-Length"] = #request_body;
        },
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body),
	}
	--[[
	print(res)
	print(code)

	if type(response_headers) == "table" then
		for k, v in pairs(response_headers) do
		  print(k, v)
		end
	end

	print("Response body:")
	if type(response_body) == "table" then
		print(table.concat(response_body))
	else
		print("Not a table:", type(response_body))
	end
	--]]
	request_body = nil -- release
	if type(response_body) == "table" then
		response_body = response_body[1]
	end
	print(response_body)
	if type(response_body) == "string" then
		response_body = json2table(response_body)
	end

	return response_body
end
------------- end http post ----------

------------- crc16 with modbus using 'crc' C lib ----------
-- input str2hex('010300020008E5CC')
-- return true/false
function crc16_check(src)
	if src == nil or string.len(src) < 3 then return false end
	local src_len = string.len(src)
	local data = string.sub(src, 1, src_len - 2)
	local crc_compare = string.sub(src, src_len - 1, src_len)
	crc_compare = hex2str(crc_compare)
	local crc_calc = crc.crc16_modbus(data)
	crc_calc = string.format("%04X", crc_calc)
	-- reverse
	local tmp = string.sub(crc_calc, 3, 4)
 	tmp = tmp .. string.sub(crc_calc, 1, 2)
 	crc_calc = tmp
	--print(crc_compare, crc_calc)
	-- compare
	if crc_compare == crc_calc then
		return true
	else 
	--	print("CRC Error -> compare:calc", crc_compare, crc_calc)
		return false
	end
end

-- input str2hex('010300020008')
-- return nil/hex '010300020008E5CC'
function crc16_build(src)
	if src == nil or string.len(src) < 1 then return nil end
	local data = src
	local crc_calc = crc.crc16_modbus(data)
	crc_calc = string.format("%04X", crc_calc)
	-- reverse
	local tmp = string.sub(crc_calc, 3, 4)
 	tmp = tmp .. string.sub(crc_calc, 1, 2)
 	crc_calc = tmp
 	src = src .. str2hex(crc_calc)
 	return src
end
------------- end crc16 with modbus using 'crc' C lib ----------

-- check file exist or not
function file_exists(path)
  local file = io.open(path, "rb")
  if file then file:close() end
  return file ~= nil
end

function get_file_len(path)
  local fh = assert(io.open(path, "rb"))
  if fh == nil then return 0 end
  local len = assert(fh:seek("end"))
  fh:close()
  return len
end

function get_file_content(path)
	 local fh = assert(io.open(path, "rb"))
	 if fh == nil then return nil end
	 local content = assert(fh:read("*a"))
	 fh:close()
	 return content
end

-- 四舍五入取整
function getIntPart(x)
	if x <= 0 then
		return math.ceil(x)
	end

	return math.floor(x+0.5)
end

-- 字符串分割
function split( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

function isTableNull(t)
	if t == nil then return true end
	if type(t) ~= 'table' then return true end
	if next(t) ~=nil then 
		return false
	end
	return true
end

function readHardwareType()
	local hardware = get_file_content("/home/share/config/hardware.type")
	if hardware == nil then
		hardware = 'DIN-EGW-N4'
	end
	hardware = string.gsub(hardware, "\n", "")
	hardware = string.gsub(hardware, "\r", "")
	return hardware
end
