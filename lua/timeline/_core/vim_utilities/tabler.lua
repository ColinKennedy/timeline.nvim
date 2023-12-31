local M = {}

--- @source https://stackoverflow.com/a/26367080
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


function M.has_value(table_, expected_value)
    for _, value in ipairs(table_) do
        if value == expected_value then
            return true
        end
    end

    return false
end


function M.copy(array)
    return _copy(array)
end


function M.extend(items, array)
    for _, item in ipairs(items)
    do
        table.insert(array, item)
    end
end


function M.filter(item_to_filter, array)
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


function M.slice(table_, first, last, step)
    local sliced = {}

    for index = first or 1, last or #table_, step or 1
    do
        sliced[#sliced + 1] = table_[index]
    end

    return sliced
end


return M
