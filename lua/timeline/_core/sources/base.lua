local M = {}

M.Source = {}


-- TODO: Tell them to override this
function M.Source:collect(self, payload)
    return {}
end



local function _get_name()
    return "Base"
end


local function _get_icon()
    return "Base"
end


function M.Source:new()
    local self = setmetatable({}, { __index = M.Source })
    self.get_icon = _get_icon
    self.get_name = _get_name

    return self
end


return M
