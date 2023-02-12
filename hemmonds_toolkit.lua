require("hemmonds_toolkit_luax.lua")
require("hemmonds_toolkit_immovableObjects.lua")
require("hemmonds_toolkit_tacShieldsControls.lua")
require("hemmonds_toolkit_scheduler.lua")
--TODO move GM buttons to separate file

_hemmonds_toolkit_data = {SPAWN_MULTIPLE_ENEMIES=false}

function reset_scenario_button(script_name)
    addGMFunction("RESET SCENARIO", function() setScenario(script_name, "None") end)
end


-- Update loop triggering all "inherited" utilities from this toolbox. 
function hemmonds_toolkit_update(delta)
    immovableObjects:update()
    tacShieldsControls:update(delta)
    scheduler_update()
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
            refil_torpedoes(arr[i])
        end
    end)
end

function gm_refill_energy_button()
    addGMFunction("Refill energy", function()
        local arr = getGMSelection()
        for i=1, #arr do
            refill_energy(arr[i])
        end
    end)
end

function gm_exec_on_gm_click_button(label, fx, multi_mode)
    if multi_mode == nil then multi_mode=false end
    addGMFunction(label, function()
        onGMClick(function(x,y)
            math.abs(0)
            fx(x,y)
            if multi_mode == false then
                onGMClick(nil)
            end
        end)
    end)
end

function addGMLabel(text)
    if text == nil then text = "--------" end
    addGMFunction(text, function() string.format("") end)
end

--- -----------------------------------
--- Convenience functions (mostly triggered by GM)
--- -----------------------------------

function refil_torpedoes(ship)
    local misTypes = {"Homing", "Nuke", "Mine", "EMP", "HVLI"}
    for j=1, #misTypes do
        ship:setWeaponStorage(misTypes[j], ship:getWeaponStorageMax(misTypes[j]))
    end
end

function refill_energy(ship)
    ship:setEnergy(ship:getMaxEnergy())
end

--- -----------------------------------
--- ENEMY SPAWNING
--- ----------------------------------- 

function gm_spawn_enemy_button(previous_menu, faction)
    addGMFunction("Spawn enemy", function() math.abs(0) gm_spawn_enemy_menu(previous_menu, faction) end)
end

function gm_spawn_enemy_menu(previous_menu, faction)
    if faction == nil then faction="Kraylor" end
    
    clearGMFunctions()
    if previous_menu ~= nil then
        addGMFunction("-From Spawn enemy", function() math.abs(0) clearGMFunctions() previous_menu() end)
    end
    
    if _hemmonds_toolkit_data.SPAWN_MULTIPLE_ENEMIES then 
        addGMFunction("in MULTI mode", function() 
            _hemmonds_toolkit_data.SPAWN_MULTIPLE_ENEMIES=false 
            gm_spawn_enemy_menu(previous_menu, faction)
        end)
    else
        addGMFunction("in SINGLE mode", function() 
            _hemmonds_toolkit_data.SPAWN_MULTIPLE_ENEMIES=true 
            gm_spawn_enemy_menu(previous_menu, faction)
        end)
    end
    
    for i, txt in ipairs({"MT52 Hornet", "MU52 Hornet", "Adder MK5", "Stalker Q7", "Phobos T3"}) do
        gm_exec_on_gm_click_button(" Add "..txt.." foe", function(x, y) math.abs(0) CpuShip():setTemplate(txt):setFaction("Romulans"):orderRoaming():setPosition(x, y) end, _hemmonds_toolkit_data.SPAWN_MULTIPLE_ENEMIES)
    end
end

function _spawn_enemy(x, y, type_name)
    onGMClick(function(x,y) 
        onGMClick(nil)
        CpuShip():setTemplate(type_name):orderRoaming():setPosition(x, y)
    end)
end

