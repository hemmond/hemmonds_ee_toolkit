--- Immovable objects library. 
--- This library allows locking objects in place so GM cannot accidentaly delete/move them. 


immovableObjects = {
    _objects = {},
    _position_locked = true     -- if true, no immovable objects cannot be moved or deleted. Not even by GM. 
}

-- Imovable objects can be respawned by calling rewpawn function (if provided) when object was deleted. Respawn function MUST return newly spawned object.
function immovableObjects:add(object, respawn_function=nil)
    local x, y = object:getPosition()
    object._immovableObjects_data = {}
    object._immovableObjects_data[x] = x
    object._immovableObjects_data[y] = y
    object._immovableObjects_data[respawn_fx] = respawn_function
    object._immovableObjects_data[respawned] = false
    
    table.insert(immovableObjects._objects, object)
end

-- Remove object from immovable objects list, so it can be moved again. 
function immovableObjects:remove(object)
    table.remove_value(immovableObjects._objects, object)
end

-- convenience function that triggers respawn function and adds it to immovable objects. Also, returns this object.
function immovableObjects:spawn(spawn_function)
    local object = spawn_function()
    immovableObjects:add(object)
    return object
end

-- This must be called from update() loop to properly keep objects locked. 
function immovableObjects:update()
    if immovableObjects._position_locked == true then
        for i, object in ipairs(immovableObjects._objects) do
            local x, y = object:getPosition()
            if object._immovableObjects_data ~= nil then
                if object:isValid() then
                    object:setPosition(object._immovableObjects_data[x], object._immovableObjects_data[y])
                else
                    if object._immovableObjects_data[respawned] == nil then
                        if object._immovableObjects_data[respawn_fx] ~= nil then
                            local new_object = object._immovableObjects_data[respawn_fx]()
                            immovableObjects:add(new_object)
                        end
                    else
                        object._immovableObjects_data[respawned] = true
                    end -- respawn check
                end -- validity check
            else
                object._immovableObjects_data[x] = x
                object._immovableObjects_data[y] = y
            end     -- if immovable X and Y are stored in object
        end     -- for loop over all immovable objects
    end     -- if position locked
    
    --TODO: remove invalid objects that are respawned. 
end

function immovableObjects:gm_button(previous_menu=nil)
    local sub_buttons_previous_menu = immovableObjects:gm_menu
    if previous_menu ~= nil then
        sub_buttons_previous_menu = previous_menu
    end

    local reload_fx = function() 
        clearGMFunctions()
        if previous_menu ~= nil then
            addGMFunction("-From Immovable objs", function() previous_menu() end)
        else
            addGMFunction(" Immovable objs", function() end)
        end
        immovableObjects:gm_lock(reload_fx)
        immovableObjects:gm_unlock(reload_fx)
    end
    
    addGMFunction("Immovable objs", reload_fx)
end

function immovableObjects:gm_lock(reload_fx)
    addGMFunction(" Lock selected objects", function() 
        foreach(getGMSelection(), immovableObjects:add)
    end)
end

function immovableObjects:gm_unlock(reload_fx)
    addGMFunction(" Unlock selected objects", function() 
        foreach(getGMSelection(), immovableObjects:remove)
    end)
end
