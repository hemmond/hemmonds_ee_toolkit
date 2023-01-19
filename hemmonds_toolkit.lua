require("hemmonds_toolkit_luax.lua")
require("hemmonds_toolkit_immovableObjects.lua")
require("hemmonds_toolkit_tacShieldsControls.lua")
--TODO move GM buttons to separate file

function reset_scenario_button(script_name)
    addGMFunction("RESET SCENARIO", function() setScenario(script_name, "None") end)
end


-- Update loop triggering all "inherited" utilities from this toolbox. 
function hemmonds_toolkit_update(delta)
    immovableObjects:update()
    tacShieldsControls:update(delta)
end


-- Crates and returns generic player ship for multi-ship of TAC+OPS 
-- @param ship: Ship to modify for the event
function hemmonds_toolkit_small_player_ship_setup(ship)
    -- Phobos M3P, 
    tacShieldsControls:init_ship(ship)
    ship:setAutoCoolant(true):commandSetAutoRepair(true)

    ship:setJumpDrive(false):setWarpDrive(false)

    ship:setWeaponStorageMax("Nuke", 0):setWeaponStorage("Nuke", 0)
    ship:setWeaponStorageMax("EMP", 0):setWeaponStorage("EMP", 0)

    
    return ship
end

--- -----------------------------------
--- GM buttons
--- -----------------------------------


--- Add GM button for manual player's victory
--- @param previous_menu: Function that will be called to return to parent menu (aka function that generates the parent menu). 
function gmVictoryButton(previous_menu)
    addGMFunction("Win scenario", function() math.abs(0) _gmVictoryYesNo(previous_menu) end)
end

--- Shows Yes/No question dialogue GM submenu with question if Human Navy should win. 
--- @param previous_menu: Function that will be called to return to parent menu (aka function that generates the parent menu). 
function gmVictoryYesNo(previous_menu)
    clearGMFunctions()
    addGMFunction("Victory?", function() string.format("") end)
    addGMFunction("Yes", function() 
        victory("Human Navy")
        clearGMFunctions()
        addGMFunction("Players have won", function() string.format("") end)
        addGMFunction("Scenario ended", function() string.format("") end)
    end)
    addGMFunction("No", function() math.abs(0) previous_menu() end)
end

function gm_refil_torpedoes_button()
    addGMFunction("Refill torpedoes", function()
        local arr = getGMSelection()
        local misTypes = {"Homing", "Nuke", "Mine", "EMP", "HVLI"}
        for i=1, #arr do
            for j=1, #misTypes do
                arr[i]:setWeaponStorage(misTypes[j], arr[i]:getWeaponStorageMax(misTypes[j]))
            end
        end
    end)
end

function gm_refill_energy_button()
    addGMFunction("Refill energy", function()
        local arr = getGMSelection()
        for i=1, #arr do
            arr[i]:setEnergy(arr[i]:getMaxEnergy())
        end
    end)
end


--- -----------------------------------
--- ENEMY SPAWNING
--- -----------------------------------

function gm_spawn_enemy_button(previous_menu)
    addGMFunction("Spawn enemy", function() math.abs(0) gm_spawn_enemy_menu(previous_menu) end)
end

function gm_spawn_enemy_menu(previous_menu)
    clearGMFunctions()
    if previous_menu ~= nil then
        addGMFunction("-From Spawn enemy", function() math.abs(0) clearGMFunctions() previous_menu() end)
    end

    addGMFunction(" Spawn MT52 Hornet",function() _spawn_enemy("MT52 Hornet") end)
    addGMFunction(" Spawn MU52 hornet",function() _spawn_enemy("MU52 Hornet") end)
    addGMFunction(" Spawn Adder MK5",function() _spawn_enemy("Adder MK5") end)

    addGMFunction(" Spawn Stalker Q7",function() _spawn_enemy("Stalker Q7") end)
    addGMFunction(" Spawn Phobos T3",function() _spawn_enemy("Phobos T3") end)
end

function _spawn_enemy(type_name)
    onGMClick(function(x,y) 
        onGMClick(nil)
        CpuShip():setTemplate(type_name):orderRoaming():setPosition(x, y)
    end)
end

