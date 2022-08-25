-- CHAOS OPERATOR! v1.1
-- Chaos Theory Noise Synth
-- by deeg
--
-- @deeg_deeg_deeg
--
-- https://github.com/deeg-deeg-deeg
--
--
-- ENC 2: choose parameter
-- ENC 3: change selected 
--        parameter
-- ENC 1: change the amount 
--        parameters will be
--        changed
--
-- KEY 2&3: select which chaos
--          theorem to use
--
--
--
--
--
MusicUtil = require("musicutil")
engine.name = 'ChaosOp' 


osc_dest = {"192.168.1.1",9001}


------ MIDI

midi_device = {} -- container for connected midi devices
midi_device_names = {}
target = 1
midi_chan = 1
midi_cc = 95

  for i = 1,#midi.vports do -- query all ports
    midi_device[i] = midi.connect(i) -- connect each device
    table.insert( -- register its name:
      midi_device_names, -- table to insert to
      "port "..i..": "..util.trim_string_to_width(midi_device[i].name,80) -- value to insert
    )
  end
  
------

Noize = include('chaosop/lib/chaosop_engine')

para_names = {"mod_a","mod_b", "multipl", "speedval", "xamo", "yamo", "mul01", "mul02", "mul03", "osc_rec", "osc_snd", "calculus", "dstyle", "scsc", "midisend", "freq01", "freq02", "freq03", "chaosth"  }


screen_names ={"A","B","MULTIPL","SPEED","X-AMNT", "Y-AMNT",
               "OSC1 VOL", "OSC2 VOL", "OSC3 VOL", "RECEIVE", "SEND", "CALCULUS", "VISUALIZE", "VIZ SCALE", "SEND MIDI",
               "FREQ01", "FREQ02", "FREQ03"
               }


title_names = {"HENON MAP", "USHIKI MAP", "HENON ATTR", "BURGERS MAP", "HOPF BIFURC", "ONE-D MAP", "CIRCLE MAP", "ROSSLER MAP", "DUFFINGTON"}
calc_names = {"+","x","y","-","*","/"}
calc_symbol ={0,1,0,1,1,1,0,1,0,
              1,0,1,0,1,0,1,0,1,
              1,0,1,1,1,1,0,1,0,
              0,0,0,1,1,1,0,0,0,
              0,0,0,0,1,0,0,0,0,
              0,0,1,0,1,0,1,0,0
}

deltas = {"0.0001","0.1","1","10","100"}
deltaval = 3
selection_target = 1
selections = 15

rnd_init = 0
freqval = 0

pb_mul = 1

h = 0.01
x0 = 0.01
y0 = -0.02
x1 = 0
y1 = 0

frcount = 1
addcount = 1
updated = true
multi = 1

whereamI = 1
x = 1
y = 1

x_arr = {}
y_arr = {}

for i=1, 127 do
      x_arr[i] = 0
      y_arr[i] = 0
end

gfx_delta = {5,5,3,3,3,3,-5,0,0}
corr_delta = {1,1,1,1,1,1,0.1,1,1}
displ_delta = {1,0.5,1,1,1,1,1,1,2}
map_delta_x = {-5,-15,-5,-5,-5,-5,10,-5,0}
map_delta_y = {5,-10,5,1,1,1,20,1,0}
scl_delta = {1,1,2,2,2,1,0.7,0.8,5}




function intro()
  
m1 = 0
n1 = 0
gox = 0.01
goy = -0.02

velocity = 127

osc_send = false
osc_receive = false

calc = 1
screen_scale = 1

screen.font_face(1)
    
screen.clear()


for i=1,200 do
  screen.clear()

    screen.font_size(8)
    screen.level(5)
    gox=1
    goy=1

    for h=1,240 do
      
      gox = h/2
      goy = math.tan(h*i)+math.sin(i*i)*10+35
      
      screen.move(gox*1.2,goy)
      screen.text(".")
      
    end
    
    screen.font_size(25)
    screen.level(math.random(10,15))
    screen.move(27,30)
    screen.text("CHAOS")
    screen.font_size(20)
    screen.move(15,45)
    screen.text("OPERATOR!")
    screen.update()
   
    
    wait(0.01)

end
  screen.clear()
  screen.update()
  
  wait(0.5)

end


function init()

  Noize.add_params()
  
  x0 = 0.01
  y0 = -0.02

  intro()
  
     
     params:set("mod_a", 2.599)
     params:set("mod_b", 2.7899)
    

  sequence = clock.run(
    function()
      while true do

      
      if params:get(para_names[10]) == 1 then
        osc_receive = true
      else
        osc_receive = false
      end
    

      if params:get(para_names[11]) == 1 then
        osc_snd = true
      else
        osc_snd = false
      end


        a = params:get("mod_a")
        b = params:get("mod_b")
        calc = params:get("calculus")
        
        if osc_receive == false then
          multi = params:get("multipl")
          speed = params:get("speedval")
        end
        
        
        xam = params:get("xamo")
        yam = params:get("yamo")
        midi_target = params:get("chaosth")
        draw_style = params:get("dstyle")
        screen_scale = params:get("scsc")
        midi_chan = params:get("midi_chan")
        midi_cc = params:get("midi_cc")
        
        
       clock.sync(0.01*speed)
        
       -- clock.get_beats()
       
      if selection_target == 1 then
         
          if updated then
            params:set("mod_a",1.35)
            params:set("mod_b", 1.3)
            x0 = 0.01
            y0 = -0.02            
            updated = false
          end
          x1 = x0*math.cos(a) - (y0 - x0*x0)*math.sin(a)
          y1 = x0*math.sin(b) + (y0*5 - x0*x0)*math.cos(b)
      
      elseif selection_target == 2 then
          
          if updated then
            params:set("mod_a",1)
            params:set("mod_b", 1)
            x0 = 0.01
            y0 = -0.02            
            updated = false
          end
        
          
          x1 = (a - x0 - b * y0) * x0
          y1 = (a - 0.282*x0 - y0) * y0
      
      elseif selection_target == 3 then 
          if updated then
            params:set("mod_a",1.306)
            params:set("mod_b", 3.07)
            x0 = 0.01
            y0 = -0.02          
            updated = false
          end
          
          x1 = a*x0*(1-x0)-x0*y0
          y1 = b+x0*y0
          
      elseif selection_target == 4 then
       
          if updated then
            params:set("mod_a",0.65)
            params:set("mod_b", 0.74)
            x0 = 0.01
            y0 = -0.02            
            updated = false
          end
          x1 = (1 - a)*x0-(y0*y0)
          y1 = (1 + b)*y0+x0*y0
          
      elseif selection_target == 5 then 
          if updated then
            params:set("mod_a",-1.648)
            params:set("mod_b", 2.25999)
            x0 = 0.01
            y0 = -0.02            
            updated = false
          end
          x1 = y0
          y1 = b + a*y0 - (x0*x0)
        
       elseif selection_target == 6 then 
          if updated then
              params:set("mod_a", 3.944)
              params:set("mod_b", 3.944)
              x0 = 0.023
              y0 = 0.023000504
            updated = false
          end
          x1 = math.abs(a*(1-x0)*x0)
          y1 = math.abs(b*(1-y0)*y0)
        
       elseif selection_target == 7 then 
          if updated then
            params:set("mod_a", 1)
            params:set("mod_b", 180)
            x0 = 0.01
            y0 = -0.02            
            updated = false
          end
          x1 = math.abs(x0 + a - (b / 2*math.pi)*math.sin(2*math.pi*x0))
          y1 = math.abs(y0 + a - (b / 2*math.pi)*math.cos(2*math.pi*y0))
        
       elseif selection_target == 8 then 
          if updated then
            params:set("mod_a", 0)
            params:set("mod_b", 1)
            x0 = 0.01
            y0 = -0.02            
            updated = false
          end
          x1 = a + a * x0 + (x0*x0) - (y0*y0)
          y1 = b + 2*x0*y0
        
       elseif selection_target == 9 then 
         if updated then
            params:set("mod_a",0.2)
            params:set("mod_b", 4)
            updated = false
            x0 = 0.01
            y0 = 0.01
          end
          x1 = y0
          y1 = -1*a*y0+x0-(a/2)*(x0*x0*x0)+math.cos(frcount*b)
        
       end
   

 
      if x1 < -220000 or x1 > 220000 then
        x0 = x1/10000000 
      else
        x0 = x1
      end
      
      if y1 < -220000 or y1 > 220000 then
        y0 = y1/10000000 
      else
        y0 = y1
      end   
 
        
      frcount = frcount+1
        
      if frcount == 10000 then
          
          if selection_target == 6 then
   
          else
            
          x0 = 0.01 + addcount*h
          y0 = -0.02 + addcount*h
          end
          
          
          addcount = addcount+1
          frcount = 0
          
          if addcount > 50 then
            addcount = 0
          end
          

      end
      
 
        
      if osc_snd then
      
        local sendx = x0*multi
        local sendy = y0*multi
        
        if sendx > 20000 then sendx = 20000 end
        if sendy > 20000 then sendy = 20000 end

        osc.send(osc_dest,"/chaos",{sendx,sendy})
        osc.send(osc_dest,"/velo",{velocity})
        --osc.send(osc_dest,"/velo",{0})
         
      end

      -- Send MIDI notes
      if params:get("midisend") == 2 then
          local rnd = math.random(0,120)
          local note = MusicUtil.freq_to_note_num(x0*multi)
        
          midi_device[target]:note_on(note,rnd,midi_chan) 
          clock.sleep(0.01)
          midi_device[target]:note_off(note,rnd,midi_chan)  
      elseif params:get("midisend") == 3 then
        local val = MusicUtil.freq_to_note_num(math.abs(x0*multi))
        local cc = params:get("midi_cc")
        midi_device[target]:cc(cc, val, midi_chan)
      end
        
        redraw()
        
        table.insert(x_arr, x0)
        table.insert(y_arr, y0)
        table.remove(x_arr, 1)
        table.remove(y_arr, 1)
       
        if calc == 1 then
          params:set("freq01", math.abs((y0*corr_delta[selection_target]))*multi*yam + math.abs((x0*corr_delta[selection_target]))*multi*xam)
        elseif calc == 2 then
          params:set("freq01", math.abs((x0*corr_delta[selection_target]))*multi*xam)  
        elseif calc == 3 then
          params:set("freq01", math.abs((y0*corr_delta[selection_target]))*multi*yam )
        elseif calc == 4 then
          params:set("freq01", math.abs((y0*corr_delta[selection_target]))*multi*yam - math.abs((x0*corr_delta[selection_target]))*multi*xam)
        elseif calc == 5 then        
          params:set("freq01", (math.abs((y0*corr_delta[selection_target]))*multi*yam) * (math.abs((x0*corr_delta[selection_target]))*multi*xam))
        elseif calc == 6 then        
          params:set("freq01", (math.abs((y0*corr_delta[selection_target]))*multi*yam) / (math.abs((x0*corr_delta[selection_target]))*multi*xam))
        end
        


      end
    end
  )
  
  

end




  
function enc(n,d)
  
  if n == 1 then
  -- set delta  
  
    deltaval = util.clamp(deltaval + d, 1, 5)
    
  
  elseif n == 2 then
  
  -- select option
    whereamI = util.clamp(whereamI + d, 1, selections)
    
  
  elseif n == 3 then
  
  -- change current value
    change = params:get(para_names[whereamI]) + d*deltas[deltaval]
    params:set(para_names[whereamI], change)
 
  end
  redraw()
end



function key(n,z)
  if n == 3 and z == 1 then
     selection_target = util.clamp(selection_target + 1, 1, 9)
     updated = true
     params:set("chaosth", selection_target)
     redraw()
  end
  
  if n == 2 and z == 1 then
      selection_target = util.clamp(selection_target - 1, 1, 9)
      updated = true
      params:set("chaosth", selection_target)
      max_val=0
      redraw()
  end
end


function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


function osc.event(path,args,from)
  
  if path == "/speed" and osc_receive then
    speed = args[1]
  elseif path == "/multi" and osc_receive then
    multi = args[1]
  end
  
end



function valupdate()
  
      change = params:get(para_names[whereamI]) + midi_delta*deltas[deltaval]
      params:set(para_names[whereamI], change)
      
end
      

function midi_to_hz(note)
  local hz = (440 / 32) * (2 ^ ((note - 9) / 12))
  return hz
end


function wait(seconds)
    local start = os.clock()
    repeat until os.clock() > start + seconds
end


function redraw()
  screen.clear()
  
  screen.font_face(1)
  screen.font_size(8)

  screen.level(12)
  screen.move(60,15)
  screen.font_size(18)

  screen.text(round(params:get("freq01"),3))
  
  screen.font_size(8)

  screen.move(62,25)
  screen.level(12)
  screen.text(round(params:get("mod_a"),4))

  screen.move(96,25)
  screen.text(round(params:get("mod_b"),4))
  
  screen.level(2)
  screen.stroke()
  screen.circle(67,36,6)
  screen.stroke()
  screen.circle(82,36,6)
  screen.stroke()
  screen.circle(97,36,6)
  screen.rect(109,31,4,25)
  screen.rect(119,31,4,25)
  screen.stroke()
  
  r1 = round(params:get("mul01"),2)/1.4
  r2 = round(params:get("mul02"),2)/1.4
  r3 = round(params:get("mul03"),2)/1.4
  
  scl = round(params:get("multipl",2))/40
  spd = round(params:get("speedval",2))/40
  
  if osc_receive then
    scl = multi/40
    spd = speed/40
  end
  
  
  screen.level(12)
  
  screen.fill()
  screen.circle(67,36,6*r1)
  screen.fill()
  screen.circle(82,36,6*r2)
  screen.fill()
  screen.circle(97,36,6*r3)
  screen.fill()
  
  screen.rect(108,31-scl+25,5,scl)
  screen.rect(118,31,5,spd)
    screen.fill()

  laenge_01 = round(params:get("xamo"),3)
  laenge_02 = round(params:get("yamo"),3)


  for k=1, laenge_01*2+1 do

    screen.move(62 + (k-1) * 2, 45)
    screen.text(".")
  end
  
  for k=1, laenge_02*2+1 do
    screen.move(62 + (k-1) * 2, 48)
    screen.text(".")
  end
  
  screen.rect(0,4,55,7)
  screen.fill()

  screen.font_size(8)
  screen.level(1)
  screen.move(1,10)
  screen.text(title_names[selection_target])
  
 
  screen.move(62,64)
  screen.text(screen_names[whereamI])
  
  screen.font_size(8)

  screen.move(105,64)
  screen.text("▲"..deltas[deltaval])
  

  
  screen.level(12)





if draw_style == 1 then

  for g=1,53 do
    
    
    
    screen.move(g, (math.abs(x_arr[g])/x_arr[g])*math.log(math.abs(x_arr[g]))*displ_delta[selection_target]*(1+multi/1000)+25+gfx_delta[selection_target])
    screen.text(".")
    
    screen.move(g, (math.abs(y_arr[g])/y_arr[g])*math.log(math.abs(y_arr[g]))*displ_delta[selection_target]*(1+multi/1000)+45+gfx_delta[selection_target])
    screen.text(".")
    
  end

elseif draw_style == 2 then
  
  for g=1,53 do

    screen.move(32 - ((math.abs(x_arr[g]) / x_arr[g]) * math.log(math.abs(x_arr[g])) * 3 * scl_delta[selection_target] * screen_scale),35 - (math.abs(y_arr[g])/y_arr[g])*(math.log(math.abs(y_arr[g]))*3 * scl_delta[selection_target] * screen_scale))
    screen.text(".")
  end
  
end



  screen.level(1)

  for i=1,16 do
    
    screen.move(60 + 2 * i,54)
    if i == calc*3-2 then
      screen.move_rel(0,2)
      screen.text("|")
      screen.move_rel(0,-2)
    else
      screen.text(".")
    end
    
    --screen.rect(57 + 5 * i,52,3,3)    
    --screen.stroke()
  
  end
  
    screen.level(1)
    screen.rect(97,51,6,6)
    screen.stroke()
    
   screen.level(10)
    
    for i=1,3 do
      for j=1,3 do
        
        if calc_symbol[(calc*9-9)+((i-1)*3+j)] == 1 then 
          screen.pixel(97+j,51+i)
          screen.fill()           
          end
          
      end
    end
    

  if osc_receive then
    screen.level(10)
    screen.rect(5,60,4,4)
    screen.fill()
  else
    screen.level(1)
    screen.rect(6,61,3,3)
    screen.stroke()
  end
  
 
  if osc_snd then
    screen.level(10)
    screen.rect(0,60,4,4) 
    screen.fill()
  else
    screen.level(1)
    screen.rect(1,61,3,3)    
    screen.stroke()
  end
  

  screen.update()
  --screen.ping ()
end
