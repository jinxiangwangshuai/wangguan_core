--[[
-- created by liuqingwei 2018-03-22
--]]

-- common function
function i2hexs(val)
	local str = string.format("%x", val)
	if (string.len(str) < 2) then
		str = "0" .. str
	end
	return str
end

function i2is(val)
	local str = string.format("%d", val)
	return str
end

-- startBit begin as 1 not 0
function hexBitGet(val, startBit, stopBit)
	local ret = 0
	local bits = bit:d2b(val)
	if stopBit == nil then
		local index = 32 - startBit + 1
		ret = bits[index]
	else
		local count = 0
		for i = startBit, stopBit, 1 do
			local index = 32 - i + 1
			if bits[index] == 1 then
				ret = ret + 2^count
			end
			count = count + 1
		end
	end
	return ret
end

function hexBitSet(src, dist, startBit, stopBit)
	local srcbits = bit:d2b(src)
	local distbits = bit:d2b(dist)
	if not stopBit then
		stopBit = 32
	end
	
	for i = startBit, stopBit, 1 do
		local index = 32 - i + 1
		srcbits[index] = distbits[32 - (i-startBit)]
	end
	return bit:b2d(srcbits)
end

bit={data32={}}
for i=1,32 do
	bit.data32[i] = 2^(32-i)
end

--bit:d2b
function bit:d2b(arg)
	local tr={}
	for i=1,32 do
		if arg >= self.data32[i] then
			tr[i]=1
			arg=arg-self.data32[i]
		else
			tr[i]=0
		end
	end
	return tr
end 

--bit:b2d
function bit:b2d(arg)
	local nr=0
	for i=1,32 do
		if arg[i] == 1 then
			nr=nr+2^(32-i)
		end
	end
	return nr
end 

--bit:xor
function bit:_xor(a,b)
	local op1=self:d2b(a)
	local op2=self:d2b(b)
	local r={}
	
	for i=1,32 do
		if op1[i]==op2[i] then
			r[i]=0
		else
			r[i]=1
		end
	end
	return self:b2d(r)
end 

--bit:_and
function bit:_and(a,b)
	local op1=self:d2b(a)
	local op2=self:d2b(b)
	local r={}
	
	for i=1,32 do
		if op1[i] == 1 and op2[i] == 1 then
			r[i] = 1
		else
			r[i] = 0
		end
	end
	return self:b2d(r)
end 

--bit:_or
function bit:_or(a,b)
	local op1=self:d2b(a)
	local op2=self:d2b(b)
	local r={}
	
	for i=1,32 do
		if op1[i] == 1 or op2[i] == 1 then
			r[i] = 1
		else
			r[i] = 0
		end
	end
	return self:b2d(r)
end 

--bit_not
function bit:_not(a)
	local op1=self:d2b(a)
	local r={}
	
	for i = 1,32 do
		if op1[i] == 1 then
			r[i] = 0
		else
			r[i] = 1
		end
	end
	return self:b2d(r)
end 

--bit:_rshift 
function    bit:_rshift(a,n)  
    local   op1=self:d2b(a)  
    local   r=self:d2b(0)  
      
    if n < 32 and n > 0 then  
        for i=1,n do  
            for i=31,1,-1 do  
                op1[i+1]=op1[i]  
            end  
            op1[1]=0  
        end  
    r=op1  
    end  
    return  self:b2d(r)  
end  
  
--bit:_lshift 
function    bit:_lshift(a,n)  
    local   op1=self:d2b(a)  
    local   r=self:d2b(0)  
      
    if n < 32 and n > 0 then  
        for i=1,n   do  
            for i=1,31 do  
                op1[i]=op1[i+1]  
            end  
            op1[32]=0  
        end  
    r=op1  
    end  
    return  self:b2d(r)  
end  

-- 设置一个int型的某一位为0或1
function bit:_set(a, pos, value)
	if pos < 1 or pos > 32 then return a end
	pos = 32 - pos + 1
	local op=self:d2b(a)
	if value == 0 then
		op[pos] = 0
	else
		op[pos] = 1
	end
	return self:b2d(op) 
end

function bit:print(ta)
	local sr=""
	for i=1,32 do
		sr=sr..ta[i]
	end
	print(sr)
end

bit8={data8={}}
for i=1,8 do
	bit8.data8[i] = 2^(8-i)
end

--bit:d2b
function bit8:d2b(arg)
	local tr={}
	for i=1,8 do
		if arg >= self.data8[i] then
			tr[8 + 1 - i]=1
			arg=arg-self.data8[i]
		else
			tr[8 + 1 - i]=0
		end
	end
	return tr
end 
--bit:b2d
function bit8:b2d(arg)
	local nr=0
	for i=1,8 do
		if arg[i] == 1 then
			nr=nr+2^(8-i)
		end
	end
	return nr
end
