local M = {}

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

--- @source https://stackoverflow.com/a/26367080
function M.copy(array)
    return _copy(array)
end

function M.extend(items, array)
    for _, item in ipairs(items)
    do
        table.insert(array, item)
    end
end

return M
