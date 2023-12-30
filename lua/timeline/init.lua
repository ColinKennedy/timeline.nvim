--- The main Timeline public API module.
---
--- @module 'timeline'
---

local configuration = require("timeline._core.configuration")
local source_registry = require("timeline._core.source_registry")

local M = {}


local function _validate_data(data)
    -- TODO: Add ~ => /home/foo conversions
end


local function _setup_autocommands()
    -- TODO: Finish this
end


local function _setup_configuration()
    data = data or {}
    data = vim.tbl_deep_extend("force", configuration._DEFAULTS, data)

    local sources = source_registry.get_all_sources()

    -- for _, source in ipairs(sources)
    -- do
    --     if source:initialize ~= nil
    --     then
    --         source:initialize()
    --     end
    -- end

    data.sources = sources
    _validate_data(data)
    configuration.DATA = data
end


function M.setup(data)
    _setup_configuration()
    _setup_autocommands()
end


return M
