local http = require("socket.http")

local util = require("lib/util")
local a,b,c,d,e,f,g = http.request("https://raw.githubusercontent.com/GuitarMusashi616/CCMidi/master/play.lua")


print(b)

for k,v in pairs(c) do
  print(k, v)
end
print(d)

