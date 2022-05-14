local midi = require "lib/midi"
local class = require "lib/class"
--local util = require "lib/util"


local sleep = sleep or function(i) print("sleep "..tostring(i)) end
local peripheral = peripheral or {find = function() end}
local speaker = peripheral.find("speaker") or {playNote = function(...) print("playNote", ...) end}


local MidiSequencer = class()

function MidiSequencer:__init(filename)
  self.filename = filename
  self.notes = {}
  self.i = 1
  self.tempo = 120
  self.division = nil
end

function MidiSequencer:record()
  local callback = self:linked_callback()
  self:_process(callback)
end

function MidiSequencer:_process(func)
  local file = assert(io.open(self.filename, "rb"))
  local tracks = midi.process(file, func)

  print("Loaded " .. tracks .. " midi tracks!")

  file:close()
end


function MidiSequencer:_get_sleeptime(ticks)
  --how long to sleep for each tick
  assert(self.division and self.tempo, "read in header first")
  if self.division % 2 then
    local ppqn = math.floor(self.division/2)
    local beats_to_sleep = ticks / ppqn
    local sec_per_beat = 60/self.tempo
    return beats_to_sleep * sec_per_beat 
  else
    error("in absolute delta time", 0)
  end  
end

function MidiSequencer:linked_callback()
  
  return function(cmd, channel, key, vel)
    if cmd == "track" then
      self.i = 1
    elseif cmd == "header" then
      self.division = vel
    elseif cmd == "setTempo" then
      if not self.notes[self.i] then
        self.notes[self.i] = {}
      end
      table.insert(self.notes[self.i], {"tempo", channel})
      
    elseif cmd == "noteOn" and vel > 0 then
      local ins
      vel = vel * 3
      if not self.notes[self.i] then
        self.notes[self.i] = {}
      end
      if key < 66 then
        ins = "bass"
        key = key - 42
      elseif 66 <= key then
        key = key - 66
        ins = "harp"
      end
      if ins then
        table.insert(self.notes[self.i], {"noteOn", ins, vel, key})
      end 
    elseif cmd == "deltatime" then
      self.i = self.i + channel
    end
  end
end

function MidiSequencer:play()
  local max = 0
  for k,v in pairs(self.notes) do
    if k > max then
      max = k
    end
  end

  local prev = 1
  for i = 1,max do
    if self.notes[i] then
      sleep(self:_get_sleeptime(i-prev))
      prev = i
      for _, note in pairs(self.notes[i]) do
        if note[1] == "noteOn" then
          speaker.playNote(note[2], note[3], note[4])
        elseif note[1] == "tempo" then
          self.tempo = note[2]
        end  
      end
    end
  end
end

local ms = MidiSequencer("batman-Brass.mid")
ms:record()
ms:play()