--- The main Timeline public API module.
---
--- @module 'timeline'
---

local configuration = require("timeline._core.configuration")
local source_registry = require("timeline._core.source_registry")

local M = {}


function M.setup(data)
    data = data or {}
    data = vim.tbl_deep_extend("force", configuration._DEFAULTS, data)

    local sources = source_registry.get_all_sources()

    configuration.DATA = data
    configuration.DATA.sources = sources
end


return M
