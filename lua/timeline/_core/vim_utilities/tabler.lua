--- Functions for working Lua tables.
---
--- @module 'timeline._core.vim_utilities.tabler'
---

local M = {}

--- Deep-copy `array`, return a new table.
---
--- @source https://stackoverflow.com/a/26367080
---
--- @param array table The data to copy.
--- @param seen table Existing values that may have already been seen.
--- @return table # The copied `array`.
---
local function _copy(array, seen)
    if type(array) ~= "table" then return array end
    if seen and seen[array] then return seen[array] end

    local seen = seen or {}
    local result = setmetatable({}, getmetatable(array))
    seen[array] = result

    for key, value in pairs(array)
    do
        result[_copy(key, seen)] = _copy(value, seen)
    end

    return result
end


--- Check if `expected_value` is in `array`.
---
--- @param array table A list-like structure of values to check within.
--- @param expected_value ... Something to find in `table`.
--- @return boolean # If `expected_value` was found, return `true`.
---
function M.has_value(array, expected_value)
    for _, value in ipairs(array) do
        if value == expected_value then
            return true
        end
    end

    return false
end


--- Deep-copy `array`, return a new table.
---
--- @source https://stackoverflow.com/a/26367080
---
--- @param array table The data to copy.
--- @return table # The copied `array`.
---
function M.copy(array)
    return _copy(array)
end


--- Append all `items` to the end of `array`.
---
--- @param items ...[] Values to add into `array`.
--- @param array table A list-like structure of values to add into.
---
function M.extend(items, array)
    for _, item in ipairs(items)
    do
        table.insert(array, item)
    end
end


--- Make a copy of `array` without any of `item_to_filter`.
---
--- @param item_to_filter ... Something to exclude from the returned array.
--- @param array table A list-like structure of values to check within.
--- @return table # The generated copy of `array`, without any of `item_to_filter`.
---
function M.filter_item(item_to_filter, array)
    local output = {}

    for _, item in ipairs(array)
    do
        if item ~= item_to_filter
        then
            table.insert(output, item)
        end
    end

    return output
end


--- Get a subset of `array` as a new array.
---
--- @param array table A list-like structure of values to check within.
--- @param first number? The first value to start looking within.
--- @param last number? The last value to include in the returned result.
--- @param step number? The increment of indices to consider for the subarray.
--- @return table # A subarray copy of `array`.
---
function M.slice(array, first, last, step)
    local sliced = {}

    for index = first or 1, last or #array, step or 1
    do
        sliced[#sliced + 1] = array[index]
    end

    return sliced
end


return M
