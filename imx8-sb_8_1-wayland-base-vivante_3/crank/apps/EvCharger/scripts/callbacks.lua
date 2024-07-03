local VIDEOS_ROOT = gre.APP_ROOT .. "/videos/"

local counter = 1
local stopper = 17
local steps = 17
local number = nil
local frame = nil
local car_state = "start"

local FPS_go = 30
local FPS_stop = 0
local video_clear = "videos/empty.mpeg"

function get_value(mapargs)
  local val = string.format(gre.get_value("road_layer.video_unplug.video"))
  local val2 = string.format(gre.get_value("road_layer.video_plug_drop.video"))
  print (val, val2)
end

function media(mapargs)  -- using video media complete events as trigger events 

  local video = string.gsub(mapargs.context_event_data.name, VIDEOS_ROOT, "")

  for k,v in pairs (mapargs.context_event_data) do 
  end

--  print (video)

  if video == "3_dot_loader1.mpeg" then
    counter = counter + 1
    if counter == 3 then
      local data = {}
          data["plug_in_layer.3_dot_loader.num"] = 0
      gre.set_data(data)
      counter = 0
--      print (counter)
      plug_in_vehicle()
    end

  elseif video == "plug_in.mpeg" then
      local data = {}
          data["road_layer.video_plug_drop.grd_hidden"] = false
          data["road_layer.video_plug_drop.alpha"] = 255  
          data["road_layer.video_unplug.alpha2"] = 0
      gre.set_data(data)

  elseif video == "processing.mpeg" then
    print ("processing payment complete")

  elseif video == "car_unplug.mpeg" then
    gre.animation_trigger("trees2")
    car_state = "unplugged"
    number = 31

    car_turn4()
    reset_positions()
  end

end

video_road = "on"

function toggle_video_road()
  local data = {}
    if video_road == "on" then
      data ["road_layer.road_1280_360.video"] = video_clear
      data ["road_layer.road_1280_360.num"] = FPS_stop
      data ["road_layer.road_1280_360.alpha"] = 0
      video_road = "off"      
    elseif video_road == "off" then
      data ["road_layer.road_1280_360.video"] = "videos/paper_road_loop.mpeg"
      data ["road_layer.road_1280_360.num"] = FPS_go
--      data ["road_layer.road_1280_360.alpha"] = 255 handled by "trees2" animation
      video_road = "on"      
    end
  gre.set_data(data)
  
end

function reset_processing()
  local data = {}
    data["payment_layer.processingGroup.video_processing.alpha_vid"] = 0    
    data["payment_layer.processingGroup.video_processing.num"] = 0 -- triggers the processing animation with the lightning bolt
    data["payment_layer.processingGroup.label_processing.grd_hidden"] = true
    data["payment_layer.processingGroup.video_processing.video"] = "videos/empty.mpeg"
  gre.set_data(data)
  
end

--//--------
--//-------- road layer
--//--------


function get_frame(mapargs)
  local num = string.format(gre.get_value("road_layer.car.image", "%d+"))
--  print (num:match("%d+"))

  frame = (num:match("%d+"))
--  print ("frame = "..(frame))
end


--// triggered by show_payment animation complete
function car_turn1(mapargs)
  local data = {}
  local number = tonumber(frame)

  rotate_car = gre.animation_create(30,1)
  data["key"] = "road_layer.car.image"

  if car_state == "start" then
    for i = 1, steps do
      if number < stopper then 
        number = number + 1

        if number > 15 then
          number = 15 -- stops at the frame to end at car15.png
          frame = number
          
        end
        
--        print (number)
        data["offset"] = i*50
        data["to"] = string.format('images/car/car%02d.png',number)
        gre.animation_add_step(rotate_car,data)

      end
    end      
  end    

  gre.animation_trigger(rotate_car)

end

function pay_to_charger(mapargs)
  get_frame()
  car_state = "pay"  
  stopper = 26
  steps = 16
end

function charger_to_charging(mapargs)
  get_frame()
  car_state = "charging"  
  stopper = 31
  steps = 16
end

function car_turn2(mapargs)
  local data = {}
  local number = tonumber(frame)

  rotate_car = gre.animation_create(30,1)
  data["key"] = "road_layer.car.image"

  if car_state == "pay" then
    for i = 1, steps do
      if number < stopper then 
        number = number + 1
        if number > stopper then
          number = stopper
        end
        print (number)
        data["offset"] = i*50
        data["to"] = string.format('images/car/car%02d.png',number)
        gre.animation_add_step(rotate_car,data)

      end
    end      

  end    

  gre.animation_trigger(rotate_car)

end

function car_turn3(mapargs)
  local data = {}
  local number = tonumber(frame)

  rotate_car = gre.animation_create(30,1)
  data["key"] = "road_layer.car.image"

  if car_state == "charging" then
    for i = 1, steps do
      if number < stopper then 
        number = number + 1
        if number > stopper then
          number = stopper
        end

        data["offset"] = i*50
        data["to"] = string.format('images/car/car%02d.png',number)
        gre.animation_add_step(rotate_car,data)

        car_state = "next"
        stopper = 31
        steps = 16
        frame = number
      end
    end      

  end    

  gre.animation_trigger(rotate_car)

end

function car_turn4(mapargs)
  local data = {}
  local number = tonumber(frame)

  rotate_car = gre.animation_create(30,1)
  data["key"] = "road_layer.car.image"

  if car_state == "unplugged" then
    for i = 1, steps do
      if number > stopper then 
        number = number - 1
        if number < stopper then
          number = stopper
        end

        data["offset"] = i*50
        data["to"] = string.format('images/car/car%02d.png',number)
        gre.animation_add_step(rotate_car,data)

      end
    end      

  end    

  gre.animation_trigger(rotate_car)

end

function charging_to_unplug(mapargs)
  get_frame()
  car_state = "unplugged"  
  stopper = 4
  steps = 30

  gre.animation_trigger("charging_complete") -- completion triggers "hide_charing_layer" animation

end


--//--------
--//-------- welcome layer
--//--------

function start_button(mapargs)
  get_frame()
  
  gre.animation_stop("trees")
  gre.animation_stop("driving1")
  gre.animation_stop("driving2")
  gre.animation_stop("driving3")
  gre.animation_stop("driving4")
  
  gre.animation_trigger("step_1")
  gre.animation_trigger("hide_start_button")
  gre.animation_trigger("show_payment")

end

--//--------
--//-------- payment layer
--//--------


function payment_next_button(mapargs)
  pay_to_charger()
  gre.animation_trigger("payment_selected")
  
end

function processing()
  local data = {}

    -- for whatever reason the video was getting different results based on the visibility of the conrol and group
--    data["payment_layer.processingGroup.grd_hidden"] = false
--    data["payment_layer.processingGroup.video_processing.grd_hidden"] = false    
    data["payment_layer.processingGroup.video_processing.video"] = "videos/processing.mpeg"
    data["payment_layer.processingGroup.video_processing.alpha_vid"] = 255    
    data["payment_layer.processingGroup.video_processing.num"] = 30 -- triggers the processing animation with the lightning bolt
    data["payment_layer.processingGroup.label_processing.grd_hidden"] = false
  gre.set_data(data)

  CBSetProcessingTimer() -- countdown before moving from payment complete to select charger

end

local timer = 5
local timerID = nil

function CBSetProcessingTimer()
  timerID = gre.timer_set_interval(CBCountdown,1000)
end

function CBCountdown(mapargs)
  if (timer>2)then
    timer = timer - 1
  elseif (timer>0) then
    gre.animation_trigger("payment_received")
    timer = timer - 1
  else
    timer = 5
    gre.timer_clear_timeout(timerID)
    gre.animation_trigger("show_select_charger")
  end
end

--//--------
--//-------- select charger layer
--//--------

function charger_selected()
  charger_to_charging()
  gre.animation_trigger("show_plug_in_vehicle")
  gre.animation_trigger("hide_select_charger")

  local data = {}
  data["plug_in_layer.3_dot_loader.video"] = "videos/3_dot_loader1.mpeg"
  data["plug_in_layer.3_dot_loader.num"] = 30 -- triggers the 3 dot loader / waiting animation
  data["plug_in_layer.3_dot_loader.alpha"] = 255
  gre.set_data(data)

end

--//--------
--//-------- charging layer
--//--------

function plug_in_vehicle()       

  local data = {}
  data["road_layer.video_plug_drop.grd_hidden"] = false
  data["road_layer.video_plug_drop.video"] = "videos/plug_in.mpeg"
  data["road_layer.video_plug_drop.num"] = 30
  data["road_layer.video_plug_drop.alpha"] = 255

  data["plug_in_layer.3_dot_loader.video"] = "videos/empty.mpeg"
  data["plug_in_layer.3_dot_loader.num"] = 0 -- stops the 3 dot loader / waiting animation
  data["plug_in_layer.3_dot_loader.alpha"] = 0

  data["charging_layer.battery_group.charge_level_cap.num"] = 30
  data["charging_layer.battery_group.charge_level_cap.video"] = "videos/charge_level_cap.mpeg"
  data["charging_layer.battery_group.charge_column_vid.num"] = 30
  data["charging_layer.battery_group.charge_column_vid.video"] = "videos/battery_column.mpeg"
  gre.set_data(data)

  gre.animation_trigger("plug_confirmation")
end

function unplug_vehicle()
  get_frame()
  toggle_video_road()
  local data = {}

  data["road_layer.video_unplug.video"] = "videos/car_unplug.mpeg"
  data["road_layer.video_unplug.num"] = 30 -- triggers unplug video
  data["road_layer.video_unplug.alpha"] = 255 -- triggers unplug video
  data["road_layer.video_unplug.alpha2"] = 255 -- triggers unplug video
  
  -- trigger animation that fades in view of the unplugging vehicle
--  gre.animation_trigger("swap_plug_in_out_fade")
  

  -- reset the vehicle plug in video FPS and alpha
  data["road_layer.video_plug_drop.video"] = "videos/empty.mpeg"
  data["road_layer.video_plug_drop.num"] = 0
  data["road_layer.video_plug_drop.alpha"] = 0
  data["road_layer.video_plug_drop.alpha2"] = 0

  gre.set_data(data)

end  


--//--------
--//-------- reset layers
--//--------

function reset_positions(mapargs)
  counter = 1
  stopper = 17
  steps = 17
  number = nil
  frame = nil
  car_state = "start"
  
  local data = {}


  -- reset battery video(s)
  data["charging_layer.battery_group.charge_column_vid.num"] = 0
  data["charging_layer.battery_group.charge_column_vid.video"] = "videos/empty.mpeg"
  

  -- unplug video
  data["road_layer.video_unplug.video"] = "videos/empty.mpeg"
  data["road_layer.video_unplug.num"] = 30 -- stops unplug video
  data["road_layer.video_unplug.alpha"] = 0
  data["road_layer.video_unplug.alpha2"] = 0


  -- plug in video
  data["road_layer.video_plug_drop.video"] = "videos/empty.mpeg"  
  data["road_layer.video_plug_drop.num"] = 30  
  data["road_layer.video_plug_drop.alpha"] = 0  
  data["road_layer.video_plug_drop.alpha2"] = 0

  -- step_1 animation reset values
  data["bg_layer.bg2.alpha"] = 0
--  data["welcome_layer.renuer_sm.grd_x"] = -250


  -- hide_start_button reset values
--  data["welcome_layer.btn_start.grd_y"] = 616
--  data["road_layer.logo_renuer.grd_y"] = 90
  
  -- show_payment reset values
  data["payment_layer.ACCEPTED.grd_x"] = 1300
  data["payment_layer.banking_logos.grd_x"] = 1300
  data["payment_layer.label_get_started.grd_x"] = 1300
  data["payment_layer.label_welcome.grd_x"] = 1300
  data["payment_layer.logo_apple_pay.grd_x"] = 1300
  data["payment_layer.logo_google_pay.grd_x"] = 1300
  data["payment_layer.logo_tap_pay.grd_x"] = 1300

  data["payment_layer.payment_selection.grd_x"] = 1300
  data["payment_layer.label_wait.alpha"] = 0
  data["payment_layer.label_wait.grd_x"] = 840


  -- btn_next_payment reset values
  data["payment_layer.processingGroup.label_processing.alpha"] = 0
  data["payment_layer.processingGroup.grd_x"] = 845
  data["payment_layer.btn_next_control.grd_x"] = 810
  data["payment_layer.btn_next_control.grd_y"] = 720
  data["payment_layer.btn_next_control.alpha"] = 255
  data["payment_layer.btn_next_control.alpha1"] = 255

  data["payment_layer.processingGroup.label_processing.grd_hidden"] = true
  data["payment_layer.processingGroup.grd_x"] = 845
  data["payment_layer.processingGroup.label_processing.grd_x"] = 121
  data["payment_layer.processingGroup.label_processing.y"] = 90
  data["payment_layer.processingGroup.label_processing.y1"] = 0
  data["payment_layer.processingGroup.video_processing.alpha_vid"] = 0    
  data["payment_layer.processingGroup.video_processing.num"] = 0
  data["payment_layer.label_wait.grd_x"] = 840

  -- charging layer reset positions
  data["select_charger.CCS_info.grd_x"] = 1663
  data["select_charger.CHAdeMO_info.grd_x"] = 1389
  data["select_charger.charger_CCS.grd_x"] = 1694
  data["select_charger.charger_CHAdeMO.grd_x"] = 1420
  data["select_charger.label_charger_direction.grd_x"] = 1323
  data["select_charger.label_select_charger.grd_x"] = 1411
  data["select_charger.charger_selector.grd_x"] = 1300
  data["select_charger.btn_next.grd_x"] = 810
  data["select_charger.btn_next.grd_y"] = 730
  data["select_charger.btn_next.alpha"] = 0
  data["select_charger.btn_next.alpha1"] = 0

  data["charging_layer.battery_group.charge_column_vid.grd_height"] = 20
  data["charging_layer.battery_group.charge_column_vid.grd_y"] = 232
  data["charging_layer.battery_group.charge_level_cap.grd_y"] = 219
  
  data["charging_layer.cost_group.cost_loader.num"] = 0

  data["charging_layer.btn_stop_control.grd_x"] = 1510
  data["charging_layer.btn_stop_control.grd_y"] = 592
  data["charging_layer.label_charging.y1"] = 44
  data["charging_layer.label_charging.y"] = 0
  data["charging_layer.label_charging_message.y1"] = 32
  data["charging_layer.label_charging_message.y"] = 0
  data["charging_layer.time_estimate_control.alpha1"] = 255
  data["charging_layer.time_estimate_control.alpha"] = 255
  
  data["plug_in_layer.3_dot_loader.grd_x"] = 1608
  data["plug_in_layer.3_dot_loader.alpha"] = 255
  data["plug_in_layer.connection_confirmation.grd_x"] = 1583
  data["plug_in_layer.connection_confirmation.x"] = -245
  data["plug_in_layer.EV_charger.grd_x"] = 1440
  data["plug_in_layer.EV_charger.x"] = 0
  data["plug_in_layer.label_confirmation.grd_x"] = 1443
  data["plug_in_layer.label_confirmation.alpha"] = 0
  data["plug_in_layer.label_plug_description.grd_x"] = 1411
  data["plug_in_layer.label_plug_description.alpha"] = 255
  data["plug_in_layer.label_plug_in.grd_x"] = 1470
  data["plug_in_layer.label_plug_in.alpha"] = 255
  data["plug_in_layer.selected.grd_x"] = 1529



  gre.set_data(data)
  

end
