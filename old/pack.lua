local key, val = ("I1"):unpack(0x000)


local a = ("I1I1"):pack(52,21)

function see(a)
  for i = 1,#a do
  
    print(a:sub(i,i):byte())
  end
  print()
end

function I1I1(bytes)
  assert(#bytes == 2, "bytes is not len 2")
  return bytes:sub(1,1):byte(), bytes:sub(2,2):byte()
end

function uint(big_endian, ...)
  
  local tArgs = {...}
  assert(#tArgs > 0)
  
  local op = function(i) return i-1 end
  if big_endian then
    op = function(i) return #tArgs-i end
  end
  
  local result = 0
  for i=1,#tArgs do
    assert(0 <= tArgs[i] and tArgs[i] <= 255, "byte must be between 0 and 255")
    result = result + tArgs[i]*256^op(i)
  end
  return result
end


function uintbe(big_endian, ...)
  
  local tArgs = {...}
  assert(#tArgs > 0)
  local result = 0
  for i=1, #tArgs do
    assert(0 <= tArgs[i] and tArgs[i] <= 255, "byte must be between 0 and 255")
    result = result + tArgs[i]*256^(i-1)
  end
  return result
end

local b = (">I1I1I1I1"):pack(100,40,25,10)
local c = ("I1I1I1I1"):pack(100,40,25,10)

see(b)
see(c)

local d = (">I3"):pack(5000)

see(d)

print(("I1I1I1I1"):unpack(c))
print((">I1I1I1I1"):unpack(c))


function string_unpack(fmt, bytes, big_endian)
  local tbl = {}
  for i=1,#bytes do
    local int = bytes:sub(i,i):byte()
    table.insert(tbl, int)
  end
  
  if fmt == "I1I1" then
    assert(#tbl == 2, ("%i ~= 2"):format(#tbl))
    return table.unpack(tbl)
  elseif fmt == "I1I1I1I1" or fmt == ">I1I1I1I1" then
    assert(#tbl == 4, ("%i ~= 4"):format(#tbl))
    return table.unpack(tbl)
  elseif fmt == ">I3" then
    assert(#tbl == 3, ("%i ~= 3"):format(#tbl))
    return uint(true, table.unpack(tbl))
  elseif fmt == ">c4I4" then
    assert(#tbl == 8, ("%i ~= 8"):format(#tbl))
    
    return bytes:sub(1,4), uint(true,tbl[5],tbl[6],tbl[7],tbl[8])
        
  elseif fmt == ">I2I2I2" then
    assert(#tbl == 6, ("%i ~= 6"):format(#tbl))
    
    return uint(true,tbl[1],tbl[2]), uint(true,tbl[3],tbl[4]), uint(true,tbl[5],tbl[6])
    
    
  end
end

print(string_unpack("I1I1I1I1", b))

print(uint(true, 0,19,136))
print(uint(false,  136, 19, 0))

print(string_unpack(">I3", d))

local f = (">c4I4"):pack("abcd", 1000)
local char, k = string_unpack(">c4I4", f)
print(char, k)



local g = (">I2I2I2"):pack(5000, 12000, 5100)
local n1, n2, n3 = string_unpack(">I2I2I2", g)
print(n1,n2,n3)


