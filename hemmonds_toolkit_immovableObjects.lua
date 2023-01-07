--- Immovable objects library. 
--- This library allows locking objects in place so GM cannot accidentaly delete/move them. 


immovableObjects = {
    _objects = {},
    _position_locked = true     -- if true, no immovable objects cannot be moved or deleted. Not even by GM. 
}

-- Imovable objects can be respawned by calling rewpawn function (if provided) when object was deleted. Respawn function MUST return newly spawned object.
function immovableObjects:add(object, respawn_function)
    local x, y = object:getPosition()
    object._immovableObjects_data = {}
    object._immovableObjects_data.x = x
    object._immovableObjects_data.y = y
    object._immovableObjects_data.respawn_fx = respawn_function
    object._immovableObjects_data.respawned = false
    object._immovableObjects_data.locked = true

    table.insert(immovableObjects._objects, object)
end

-- Remove object from immovable objects list, so it can be moved again. 
function immovableObjects:remove(object)
    object._immovableObjects_data.locked = false
end

-- convenience function that triggers respawn function and adds it to immovable objects. Also, returns this object.
function immovableObjects:spawn(spawn_function)
    local object = spawn_function()
    immovableObjects:add(object, spawn_function)
    return object
end

-- This must be called from update() loop to properly keep objects locked. 
function immovableObjects:update()
    if immovableObjects._position_locked == true then
        for i, object in ipairs(immovableObjects._objects) do
            local x, y = object:getPosition()
            if object._immovableObjects_data ~= nil and object._immovableObjects_data.locked == true then
                if object:isValid() then
                    object:setPosition(object._immovableObjects_data.x, object._immovableObjects_data.y)
                else
                    if object._immovableObjects_data.respawned == nil or object._immovableObjects_data.respawned == false then
                        if object._immovableObjects_data.respawn_fx ~= nil then
                            local new_object = object._immovableObjects_data.respawn_fx()
                            new_object:setPosition(object._immovableObjects_data.x, object._immovableObjects_data.y)
                            immovableObjects:add(new_object, object._immovableObjects_data.respawn_fx)
                        end
                        object._immovableObjects_data.respawned = true
                    end -- respawn check
                end -- validity check
            else
                object._immovableObjects_data.x = x
                object._immovableObjects_data.y = y
            end     -- if immovable X and Y are stored in object
        end     -- for loop over all immovable objects
    end     -- if position locked
    
    --TODO: remove invalid objects that are respawned. 
end

function immovableObjects:gm_button(previous_menu)
    if previous_menu == nil then
        --if no previous menu is given, this function will insert itself as the only function that has been called to draw this button.
        previous_menu = function()
            immovableObjects:gm_button()
        end
    end
    addGMFunction("Immovable objs.", function() immovableObjects:_gm_submenu(function() previous_menu() end) end)
end

function immovableObjects:_gm_submenu(previous_menu)
    clearGMFunctions()
    addGMFunction("-From Immovable objs", function() math.abs(0) clearGMFunctions() previous_menu() end)
    immovableObjects:gm_lock(function() math.abs(0) immovableObjects:_gm_submenu(previous_menu) end)
    immovableObjects:gm_unlock(function() math.abs(0) immovableObjects:_gm_submenu(previous_menu) end)

--    addGMFunction("info", function()
--        foreach(getGMSelection(), function(object)
--            local x,y = object:getPosition()
--            addGMMessage("Locked object:\n" ..
--            "xs: " .. object._immovableObjects_data.x .. "\n" ..
--            "ys: " .. object._immovableObjects_data.y .. "\n" ..
--            "xa: " .. x .. "\n" .. "ya: " .. y)
--        end)
--    end)
end

function immovableObjects:gm_lock(previous_menu)
    addGMFunction(" Lock selected objects", function() 
        foreach(getGMSelection(), function(object)
            immovableObjects:add(object, object._immovableObjects_data.respawn_fx)
        end)
        clearGMFunctions()
        addGMFunction("-Locked, continue", function() math.abs(0) previous_menu() end)
    end)
end

function immovableObjects:gm_unlock(previous_menu)
    addGMFunction(" Unlock selected objects", function() 
        foreach(getGMSelection(), function(object)
            immovableObjects:remove(object)
        end)
        clearGMFunctions()
        addGMFunction("-Unlocked, continue", function() math.abs(0) previous_menu() end)
    end)
end
