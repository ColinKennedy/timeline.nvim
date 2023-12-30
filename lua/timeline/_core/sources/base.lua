local configuration = require("timeline._core.configuration")

local M = {}

M.Source = {}


-- TODO: Tell them to override this
function M.Source:collect(self, payload)
    return {}
end



function M.Source:get_name(self)
    return "Base"
end


function M.Source:get_icon(self)
    return configuration.DATA.sources[self:get_type()].icon
end


function M.Source:new()
    local self = setmetatable({}, { __index = M.Source })

    return self
end


return M
