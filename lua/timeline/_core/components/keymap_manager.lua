--- Set up mappings for the Terminal Viewer.
---
--- @module 'timeline._core.components.keymap_manager'
---

local configuration = require("timeline._core.configuration")
local keymap = require("timeline._core.vim_utilities.keymap")

local M = {}


--- Add normal / visual mappings to `timeline_buffer`.
---
--- @param timeline_buffer number The buffer to add mappings onto.
--- @param source_buffer number A reference buffer that pairs with the timeline_buffer.
--- @param data KeymapPrototype The mapping to apply.
--- @param modes string[] The Vim mode to apply the mapping for. e.g. `{"n", "v"}`.
---
local function _add_mappings(timeline_buffer, source_buffer, data, modes)
    modes = modes or {"n"}

    for _, mode in ipairs(modes)
    do
        vim.keymap.set(
            mode,
            data.key,
            function()
                data.command(timeline_buffer, source_buffer)
            end,
            { buffer=timeline_buffer, desc=data.description }
        )
    end
end


--- Add normal / visual mappings to `timeline`.
---
--- @param timeline_buffer number The buffer to add mappings onto.
--- @param source_buffer number A reference buffer that pairs with the timeline_buffer.
---
function M.initialize_buffer_mappings(timeline, source)
    keymap.unmap_all(timeline)

    _add_mappings(timeline, source, configuration.DATA.mappings.open, { "n", "v" })
    _add_mappings(timeline, source, configuration.DATA.mappings.restore)
    _add_mappings(timeline, source, configuration.DATA.mappings.show_diff, { "n", "v" })
    _add_mappings(timeline, source, configuration.DATA.mappings.show_manifest)
    _add_mappings(timeline, source, configuration.DATA.mappings.view_this)
end


return M
