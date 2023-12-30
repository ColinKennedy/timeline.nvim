--- The entry point for displaying a timeline.
---
--- @module 'timeline.viewer'
---

local request = require("timeline._core.request")
local tabler = require("timeline._core.utilities.tabler")

local M = {}


local function _create_viewer()
end


function M.view_current()
    local path = vim.fn.expand("%:p")
    M.view(path)
end


function M.view(path)
    local sources = source_registry.get_sources()

    local window = _create_viewer()
    local height = vim.api.nvim_win_get_height(window)
    local offset = 0
    local payload = request:new(path, window, height, offset)

    local results = {}

    for _, source in ipairs(sources)
    do
        tabler.extend(source:collect(payload), results)
    end

    print(vim.inspect(results))
end
