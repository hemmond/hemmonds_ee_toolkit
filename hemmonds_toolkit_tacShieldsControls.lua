--- This script allows adding crude shields controls to tactical console
---
--- API: 
--- * tacShieldsControls:init_ship(player_ship) = add shields controls to Tactical
--- * tacShieldsControls:update()   = Module's update loop. Must be in scenairo update function (if used as part of hemmond's sandbox, use its main update loop). 

require("hemmonds_toolkit_luax.lua")

tacShieldsControls = {
    _initialized = false,
    _ships = {}, 
    
    _BTN_OFF = "shields_off",
    _BTN_ON = "shields_on",
    _BTN_CALIBRATE = "calibrate"
}

-- Initialize shield controls on player_ship's tactical console.
function tacShieldsControls:init_ship(player_ship)
    table.insert(tacShieldsControls._ships, player_ship)
    tacShieldsControls:_process_buttons(player_ship)
end

-- Process adding correct button
function tacShieldsControls:_process_buttons(player_ship)
    player_ship:removeCustom(tacShieldsControls._BTN_OFF)
    player_ship:removeCustom(tacShieldsControls._BTN_ON)
        
    if player_ship:getShieldsActive() then
        player_ship:addCustomButton("Tactical", tacShieldsControls._BTN_OFF, "Shields: ON", function() 
            player_ship:commandSetShields(false)
            --tacShieldsControls:_process_buttons(player_ship)
        end)
    else
        player_ship:addCustomButton("Tactical", tacShieldsControls._BTN_ON, "Shields: OFF", function() 
            player_ship:commandSetShields(true)
            --tacShieldsControls:_process_buttons(player_ship)
        end)
    end
    --TODO: Add calibrate button that will retrieve current beam frequency when calibration is triggered.
    
--    if areBeamShieldFrequenciesUsed() then
--        player_shipaddCustomButton("Tactical", tacShieldsControls._BTN_CALIBRATE, "Calibrate", function() 
--            player_ship:commandSetShieldFrequency(true)
--        end)
--    end
end

--
function tacShieldsControls:update()
    --Update TAC shields controls (it is here because other console could change shields state)
    foreach(tacShieldsControls._ships, function(object)
        if object ~= nil and object.typeName == "PlayerSpaceship" then
            tacShieldsControls:_process_buttons(object)
        end
    end)
end
