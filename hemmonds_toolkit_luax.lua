--- This script contain LUA convenience functions (Generic LUA functions, not using EE API)

-- Removes table entry containing value from table
-- @param list: lua table from which the entry should be removed
-- @param value: Content of table value (thing you get when accessing table by key)
function table.remove_value(list, value)
    for index, value in pairs(list) do
        if value == el then
            table.remove(list, index)
        end
    end
end

function foreach(list, fx)
    for i, object in ipairs(list) do
        fx(object)
    end
end