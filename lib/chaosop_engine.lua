local ChaosOp = {}
local Formatters = require 'formatters'


local specs = {
  
  
  ["mul01"] = controlspec.new(0, 1, "lin", 0, 1, ""),
  ["mul02"] = controlspec.new(0, 1, "lin", 0, 0, ""),
  ["mul03"] = controlspec.new(0, 1, "lin", 0, 0, ""),
  
  ["freq01"] = controlspec.new(0, 20000, "lin", 0, 20, "Hz"),
  ["freq02"] = controlspec.new(0, 20000, "lin", 0, 20, "Hz"),
  ["freq03"] = controlspec.new(0, 20000, "lin", 0, 20, "Hz")
}


local mnames = {

  ["mul01"] = "OSC 01 Volume",
  ["mul02"] = "OSC 02 Volume",
  ["mul03"] = "OSC 03 Volume",

  ["freq01"] = "OSC 01 Frequency",
  ["freq02"] = "OSC 02 Frequency",
  ["freq03"] = "OSC 03 Frequency"
  
}

  params:add_separator("MIDI SETUP")
  params:add_option("midisend","MIDI Send",{"OFF", "NOTES", "CC", "X NOTE, Y CC"}, 1)
  params:add_option("midi target", "MIDI Target",midi_device_names, 1)
  params:set_action("midi target", function(x) target = x end)
  params:add_number("midi_chan_x", "MIDI X Channel", 1, 100, 1)
  params:add_number("midi_cc_x",   "MIDI X CC",      1, 128, 95)
  params:add_number("midi_chan_y", "MIDI Y Channel", 1, 100, 2)
  params:add_number("midi_cc_y",   "MIDI Y CC",      1, 128, 95)

  params:add_separator("Basic Control")
  
  params:add_control("mod_a", "A", controlspec.new(-1000, 1000, "lin", 0, 1, ""))
  params:add_control("mod_b", "B", controlspec.new(-1000, 1000, "lin", 0, 1, ""))
  params:add_control("multipl", "Mod Multiplier", controlspec.new(1, 1000, "lin", 0, 1, ""))
  params:add_control("speedval", "Speed", controlspec.new(1, 1000, "lin", 0, 1, ""))
  
  params:add_control("xamo", "X Amount", controlspec.new(0, 10, "lin", 0, 1, ""))
  params:add_control("yamo", "y Amount", controlspec.new(0, 10, "lin", 0, 1, ""))
  
  
-- this table establishes an order for parameter initialization:
local param_names = {"mul01", "mul02", "mul03","freq01", "freq02", "freq03"}

-- initialize parameters:
function ChaosOp.add_params()
  params:add_separator("Noize Mod")

  for i = 1,6 do
    local p_name = param_names[i]
    local x_name = mnames[i]
    params:add{
      type = "control",
      id = p_name,
      name = mnames[p_name],
      controlspec = specs[p_name],
      formatter = p_name == "pan" and Formatters.bipolar_as_pan_widget or nil,
      -- every time a parameter changes, we'll send it to the SuperCollider engine:
      action = function(x) engine[p_name](x) end
    }
  end
  

  params:add_option("osc_rec","OSC Receive",{"on", "off"},2)
  params:add_option("osc_snd","OSC Send",{"on", "off"},2)
  params:add_option("calculus","Calculus",{"x+y", "x","y","x-y","x*y","x/y"},1)
  params:add_option("dstyle","Draw Style",{"Lines", "Map"},1)
  params:add_control("chaosth", "Theorem", controlspec.new(1, 9, "lin", 0, 1, ""))
  params:add_control("scsc", "ScreenScale", controlspec.new(0.1, 1000, "lin", 0, 1, ""))
  
  params:bang()
end

-- a single-purpose triggering command fire a note
function ChaosOp.trig(hz)
  if hz ~= nil then
    engine.freq(hz)
  end
end

 -- we return these engine-specific Lua functions back to the host script:
return ChaosOp
