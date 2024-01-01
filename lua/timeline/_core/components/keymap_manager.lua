local configuration = require("timeline._core.configuration")
local keymap = require("timeline._core.vim_utilities.keymap")

local M = {}


-- buffer = source buffer
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

function M.initialize_buffer_mappings(timeline, source)
    keymap.unmap_all(timeline)

    _add_mappings(timeline, source, configuration.DATA.mappings.open, { "n", "v" })
    _add_mappings(timeline, source, configuration.DATA.mappings.restore)
    _add_mappings(timeline, source, configuration.DATA.mappings.show_diff, { "n", "v" })
    _add_mappings(timeline, source, configuration.DATA.mappings.show_manifest)
    _add_mappings(timeline, source, configuration.DATA.mappings.view_this)
end


return M
