local M = {}


function M.starts_with(full, prefix)
    return full:sub(1, #prefix) == prefix
end


return M
