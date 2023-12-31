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


function M.Request:new(path, height, offset)
    local object = {};
    setmetatable(object, self)
    self.__index = self

    object.height = height
    object.offset = offset
    object.path = path

    return object
end


return M
