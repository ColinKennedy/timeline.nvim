local base = require("timeline._core.sources.base")

local M = {}

M.Source = base.Source:new()


local function _collect(self, payload)
    -- TODO: Finish
    return {}
end

M.Source.collect = _collect


return M
