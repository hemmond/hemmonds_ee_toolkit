require("hemmonds_toolkit_luax.lua")
require("hemmonds_toolkit_immovableObjects.lua")

function reset_scenario()
    addGMFunction("RESET SCENARIO", function() setScenario("scenario_000_empty.lua", "None") end)
end


function hemmonds_toolkit_update(delta)
    immovableObjects:update()
end
