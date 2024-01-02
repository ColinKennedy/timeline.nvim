-- TODO: Add docstrings

local M = {}

M.Request = {
    new = function(path, height, offset)
        return {
            height = height,
            offset = offset,
            path = path,
        }
    end
}


function M.Request:new(path, height, offset, source_window)
    local object = {}
    setmetatable(object, self)
    self.__index = self

    object.height = height
    object.offset = offset
    object.path = path
    object.source_window = source_window

    return object
end


return M
