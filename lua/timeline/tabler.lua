local M = {}

function M.extend(items, array)
    for _, item in ipairs(items)
    do
        table.insert(array, item)
    end
end

return M
