--- The main Timeline public API module.
---
--- @module 'timeline'
---

local configuration = require("timeline._core.configuration")
local source_registry = require("timeline._core.components.source_registry")

local M = {}


--- Ensure `data` is correctly authored
---
--- @param data TimelineConfiguration User-provided settings to check.
--- @return boolean # If the data is valid, return `true`. Otherwise fail with a message.
---
local function _validate_data(data)
    paths = data.repository_paths

    if vim.tbl_isempty(paths)
    then
        vim.api.nvim_err_writeln('"repository_paths" key cannot be empty.')

        return false
    end

    local repository_paths = {}

    for _, path in ipairs(paths)
    do
        if not vim.fn.isdirectory(path)
        then
            vim.api.nvim_err_writeln(
                string.format('"repository_paths" key "%s" does not exist.', path)
            )

            return false
        end

        table.insert(repository_paths, vim.fn.expand(path))
    end

    data.repository_paths = repository_paths
    -- TODO: Check the other keys and stuff

    return true
end


local function _setup_autocommands()
    -- TODO: Finish this
end


--- Apply configuration options to timeline.nvim.
---
--- @param data TimelineConfiguration The settings which control timeline.nvim.
---
local function _setup_configuration(data)
    local data = data or {}
    data = vim.tbl_deep_extend("force", configuration._DEFAULTS, data)
    _validate_data(data)

    local sources = source_registry.create_sources()

    -- for _, source in ipairs(sources)
    -- do
    --     if source:initialize ~= nil
    --     then
    --         source:initialize()
    --     end
    -- end

    configuration.DATA = data
    source_registry.SOURCES = sources
end


--- Initialize this plugin so it can run
---
--- @param data TimelineConfiguration The settings which control timeline.nvim.
---
function M.setup(data)
    _setup_configuration(data)
    _setup_autocommands()
end


return M
