--- Settings used at various points in timeline.nvim's execution.
---
--- It controls things like keymaps, window sizes, where repositories are
--- searched within, etc.
---
--- @module 'timeline._core.configuration'
---

local action_triage = require("timeline._core.components.action_triage")
local constant = require("timeline._core.constant")

local M = {}

--- @class TimelineConfiguration
--- @field mappings table<string, KeymapPrototype>
---     Psuedo-keys to run in the Timeline buffer.
--- @field repository_paths string[]
---     Absolute paths on-disk used to look for backup locations.
---     Normally this list is just a single backup directory but if you need
---     multiple directories, you specify them here.
--- @field sources table<string, SourceConfiguration>
---     Customization options for each specific source type.
--- @field timeline_window table<string, integer>
---     This controls how the Timeline Viewer opens / displays.

--- @class KeymapPrototype
--- @field key string
---     The keymap used to trigger the command.
--- @field command func(number, number): nil
---     A function to call when the mapping runs. The input parameters are the
---     Timeline buffer and Source buffer and are provided just before execution.
--- @field description string
---     The details about what the keymap does.

--- @class SourceConfiguration
--- @field icon string?
---     An optional prefix to add to any Record that the Timeline Viewer displays.

M._DEFAULTS = {
    mappings = {
        open = {
            key = "o",
            command = action_triage.run_open_action,
            description = "Run the default-[o]pen for 1+ records, if allowed.",
        },
        restore = {
            key = "u",
            command = action_triage.run_restore_action,
            description = "[u]ndo / restore to the current record.",
        },
        show_diff = {
            key = "d",
            command = action_triage.run_show_diff_action,
            description = "Create a [d]iff of the 1+ records, if allowed.",
        },
        show_manifest = {
            key = "m",
            command = action_triage.run_show_manifest_action,
            description = "Show [m]anifest for 1+ records, if allowed. e.g. show its internal/debug details.",
        },
    },
    repository_paths = {vim.fn.expand("~/.vim_custom_backups")},
    sources = {
        [constant.SourceTypes.file] = { icon = "" },
        [constant.SourceTypes.git] = { icon = "󰜘" },
    },
    timeline_window = {
        size = 20,
        -- TODO: Add window defaults (width [percentage, fixed width, etc])
        -- size = "%20",
    }
}

M.DATA = {}


return M
