local action_triage = require("timeline._core.components.action_triage")

local M = {}

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
        file = { icon = "" },
        git = { icon = "󰜘" },
    },
    timeline_window = {
        size = 20,
        -- TODO: Add window defaults (width [percentage, fixed width, etc])
        -- size = "%20",
    }
}

M.DATA = {}

return M
