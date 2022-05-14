local midi = require "midi"
--local speaker = peripheral.find("speaker")

local file = assert(io.open(..., "rb"))

local notes = {}
local i = 1
local tempo = 120
local division

function get_sleeptime(ticks)
  --how long to sleep for each tick
  if division % 2 then
    local ppqn = math.floor(division/2)
    local beats_to_sleep = ticks / ppqn
    local sec_per_beat = 60/tempo
    return beats_to_sleep * sec_per_beat 
  else
    error("in absolute delta time", 0)
  end  
end

function add_to_notes(cmd, channel, key, vel)
  if cmd == "track" then
    i = 1
  elseif cmd == "header" then
    division = vel
  
  
  elseif cmd == "setTempo" then
    if not notes[i] then
      notes[i] = {}
    end
    table.insert(notes[i], {"tempo", channel})
    
  elseif cmd == "noteOn" and vel > 0 then
    local ins
    vel = vel * 3
    if not notes[i] then
      notes[i] = {}
    end
    
    if key < 66 then
      ins = "bass"
      key = key - 42
    elseif 66 <= key then
      key = key - 66
      ins = "harp"
    end
    if ins then
      table.insert(notes[i], {"noteOn", ins, vel, key})
    end 
    
    
  elseif cmd == "deltatime" then
    i = i + channel
  end
end

local tracks = midi.process(file, add_to_notes)

print("Loaded " .. tracks .. " midi tracks!")

file:close()

local max = 0
for k,v in pairs(notes) do
  if k > max then
    max = k
  end
end

local prev = 1
for i = 1,max do
  if notes[i] then
    
    sleep(get_sleeptime(i-prev))
    prev = i
    for _, note in pairs(notes[i]) do
      if note[1] == "noteOn" then
        speaker.playNote(note[2], note[3], note[4])
      elseif note[1] == "tempo" then
        tempo = note[2]
      end  
    end
  end
end