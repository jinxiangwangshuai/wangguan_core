package.path = package.path .. ";./?.lua;../libs/?.lua;/home/share/core/libs/?.lua"
package.cpath = package.cpath..";./?.so;../libc/?.so;/home/share/core/libc/?.so"

local luasql = require"luasql.sqlite3"

local db_file = '/home/share/core/base.db'

basedb = {}

local function enumSimpleTable(t)  
         print"-------------------"  
         for k,v in pairs(t) do  
                   print(k, " = ", v)  
         end  
         print"-------------------\n"  
end  
  
local function rows(cur)  
         return function(cur)  
                   local t = {}  
                   if(nil~= cur:fetch(t, 'a')) then return t  
                   else return nil end  
         end,cur  
end 

local function deep_copy( obj )
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

function basedb.get_data()
	local result = nil
	local env = assert(luasql.sqlite3())  
	local db =assert(env:connect(db_file))
	local sql = [[SELECT * FROM base WHERE id=1]] --'select * from base where id=1'
	local res = assert(db:execute(sql))
	--colnames = res:getcolnames()  
	--coltypes = res:getcoltypes()  
	--enumSimpleTable(colnames)  
	--enumSimpleTable(coltypes)  
	--print(res)
	for r in rows(res) do  
	    if r.id == 1 then
	    	result = deep_copy(r)
	    	break
	    end  
	end
	
	res:close()
	db:close()
	env:close()
	return result
end

function basedb.set_data(param)
	if param == nil then return end
	local env = assert(luasql.sqlite3())  
	local db = assert(env:connect(db_file))
	db:setautocommit(false)
	local sql = "update base set"
	for k,v in pairs(param) do
		if k ~= nil and v ~= nil then
			sql = sql .. " " .. k .. "='" .. v .. "',"
		end
	end
	
	if string.sub(sql, string.len(sql), -1) == ',' then
		sql = string.sub(sql, 1, -2)
		sql = sql .. " where id=1"
		--print(sql)
		local res = assert(db:execute(sql))
		assert(db:commit())
	end
	
	db:close()
	env:close()
end

function basedb.set_status(status)
	local env = assert(luasql.sqlite3())  
	local db = assert(env:connect(db_file))
	db:setautocommit(false)
	local sql = "update base set status='" .. status .. "' where id=1"
	local res = assert(db:execute(sql))
	assert(db:commit())
	db:close()
	env:close()
end

function basedb.set_name(name)
	local env = assert(luasql.sqlite3())  
	local db = assert(env:connect(db_file))
	db:setautocommit(false)
	local sql = "update base set name='" .. name .. "' where id=1"
	local res = assert(db:execute(sql))
	assert(db:commit())
	db:close()
	env:close()
end

function basedb.set_network(ip, netmask, gateway)
	local env = assert(luasql.sqlite3())  
	local db = assert(env:connect(db_file))
	db:setautocommit(false)
	local sql = "update base set default_ip='"..ip.."', default_netmask='"..netmask.."', default_gateway='"..gateway.."' where id=1"
	local res = assert(db:execute(sql))
	assert(db:commit())
	db:close()
	env:close()
end

--basedb.set_network('192.168.2.80', '255.255.255.0', '192.168.2.1')

function basedb.get_webconfig_data()
	local result = nil
	local env = assert(luasql.sqlite3())  
	local db =assert(env:connect(db_file))
	local sql = [[SELECT * FROM webconfig WHERE id=1]] --'select * from base where id=1'
	local res = assert(db:execute(sql))
	--colnames = res:getcolnames()  
	--coltypes = res:getcoltypes()  
	--enumSimpleTable(colnames)  
	--enumSimpleTable(coltypes)  
	--print(res)
	for r in rows(res) do  
	    if r.id == 1 then
	    	result = deep_copy(r)
	    	break
	    end  
	end
	
	res:close()
	db:close()
	env:close()
	return result
end

-- param = {enabled:1, url='http://...', width=800, height=600}
function basedb.set_webconfig(param)
	if param == nil then return end
	local env = assert(luasql.sqlite3())  
	local db = assert(env:connect(db_file))
	db:setautocommit(false)
	local sql = "update webconfig set"
	for k,v in pairs(param) do
		if k ~= nil and v ~= nil then
			sql = sql .. " " .. k .. "='" .. v .. "',"
		end
	end
	
	if string.sub(sql, string.len(sql), -1) == ',' then
		sql = string.sub(sql, 1, -2)
		sql = sql .. " where id=1"
		--print(sql)
		local res = assert(db:execute(sql))
		assert(db:commit())
	end
	
	db:close()
	env:close()
end