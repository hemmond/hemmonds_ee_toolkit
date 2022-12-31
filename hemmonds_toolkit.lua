require("hemmonds_toolkit_luax.lua")
require("hemmonds_toolkit_immovableObjects.lua")


function reset_scenario()
    addGMFunction("RESET SCENARIO", function() setScenario("scenario_000_empty.lua", "None") end)
end


-- Update loop triggering all "inherited" utilities from this toolbox. 
function hemmonds_toolkit_update(delta)
    immovableObjects:update()
end
