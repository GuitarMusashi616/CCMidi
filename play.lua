local midi = require "midi"

local short_tune = "short-tune.mid"
local batman = "batman-Brass.mid"
local file = assert(io.open(batman, "rb"))

local notes = {}
local i = 1
function add_to_notes(cmd, channel, key, vel)
  if cmd == "track" then
    i = 1
  elseif cmd == "noteOn" and vel > 0 then
    key = key - 30
    vel = vel * 3
    if not notes[i] then
      notes[i] = {}
    end
    if #notes[i] < 8 then
      table.insert(notes[i], {key, vel})
    end
  elseif cmd == "deltatime" then
    i = i + channel
  end
end

local tracks = midi.process(file, add_to_notes)

print("Loaded " .. tracks .. " midi tracks!")

file:close()

function sleep(k)
  print("sleep "..tonumber(k))
end

local max = 0
for k,v in pairs(notes) do
  if k > max then
    max = k
  end
end

local prev = 1
for i = 1,max do
  if notes[i] then
    sleep((i-prev)/1000)
    prev = i
    for _, note in pairs(notes[i]) do
      print(note[1], note[2])
    end
  end
end