require("hemmonds_toolkit_luax.lua")
require("hemmonds_toolkit_immovableObjects.lua")
require("hemmonds_toolkit_tacShieldsControls.lua")


function reset_scenario(script_name)
    addGMFunction("RESET SCENARIO", function() setScenario(script_name, "None") end)
end


-- Update loop triggering all "inherited" utilities from this toolbox. 
function hemmonds_toolkit_update(delta)
    immovableObjects:update()
    tacShieldsControls:update(delta)
end
