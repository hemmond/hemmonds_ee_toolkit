--- This script contain LUA convenience functions (Generic LUA functions, not using EE API)
---
--- API: 
--- * table.remove_value(list, value)   = removes table entry by value
--- * foreach(list, fx)                 = executes fx(object) on every item in list, gives item as object parameter to fx()

-- Removes table entry containing value from table
-- @param list: lua table from which the entry should be removed
-- @param value: Content of table value (thing you get when accessing table by key)
-- TODO: verify that this works even for EE objects
function table.remove_value(list, value)
    for index, value in pairs(list) do
        if value == el then
            table.remove(list, index)
        end
    end
end

-- Runs function on every element of list
-- @param list: List on which elements functions should be run. 
-- @param fx: Function to be run on every element. This function must get exactly one argument - the element from the list.
function foreach(list, fx)
    for i, object in ipairs(list) do
        fx(object)
    end
end
