local base = require("timeline._core.sources.base")
local constant = require("timeline._core.constant")
local tabler = require("timeline._core.vim_utilities.tabler")


local M = {}

M.Source = base.Source:new()


local function _collect(payload, icon)
end


function M.Source:get_type()
    return constant.SourceTypes.restore
end


function M.Source:collect(payload)
    local results = base.Source.collect(self, payload)

    -- TODO: Finish this, later
    -- tabler.extend(_collect(payload, self:get_icon()), results)

    return results
end


function M.Source:new()
    local instance = base.Source:new(instance)
    setmetatable(instance, self)
    self.__index = self

    return instance
end


return M
