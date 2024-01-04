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
--- @field git_executable string
---     Either a command on PATH or an absolute path to some git executable.
--- @field mappings table<string, KeymapPrototype>
---     Psuedo-keys to run in the Timeline buffer.
--- @field backup_repository_path string
---     The folder on-disk that is used to make new commits.
--- @field source_repository_paths string[]
---     Absolute paths on-disk used to look for backup locations.
---     Normally this is just `backup_repository_path` but if you have
---     a special setup that requires multiple backup directories, you can.
--- @field sources table<string, SourceConfiguration>
---     Customization options for each specific source type.
--- @field timeline_window table<string, integer>
---     This controls how the Timeline View opens / displays.

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
---     An optional prefix to add to any Record that the Timeline View displays.

local _BACKUP_DIRECTORY = vim.fn.expand("~/.vim_custom_backups")

M._DEFAULTS = {
    git_executable = "git",
    mappings = {
        open = {
            key = "<leader>o",
            command = action_triage.run_open_action,
            description = "Run the default-[o]pen for 1+ records, if allowed.",
        },
        refresh = {
            key = "<leader>r",
            command = action_triage.run_refresh_action,
            description = "[r]efresh the Timeline View buffer.",
        },
        restore = {
            key = "<leader>u",
            command = action_triage.run_restore_action,
            description = "[u]ndo / restore to the current record.",
        },
        show_diff = {
            key = "<leader>d",
            command = action_triage.run_show_diff_action,
            description = "Create a [d]iff of the 1+ records, if allowed.",
        },
        show_git = {
            key = "<leader>g",
            command = action_triage.run_show_git_action,
            description = "Show [g]it commit information for 1 record.",
        },
        show_manifest = {
            key = "<leader>m",
            command = action_triage.run_show_manifest_action,
            description = "Show [m]anifest for 1+ records, if allowed. e.g. show its internal/debug details.",
        },
        view_this = {
            key = "<leader>v",
            command = action_triage.run_view_this_action,
            description = "[v]iew the Record as a file (if able).",
        },
    },
    backup_repository_path = _BACKUP_DIRECTORY,
    source_repository_paths = {_BACKUP_DIRECTORY},
    records = {
        [constant.RecordTypes.file_save] = { enabled = true, icon = "" },
        [constant.RecordTypes.git_commit] = { enabled = true, icon = "󰜘" },
        [constant.RecordTypes.restore] = { enabled = true, icon = "󰑏" },
        [constant.RecordTypes.undo_redo] = { enabled = true, icon = "" },
    },
    timeline_window = {
        size = 20,
        -- TODO: Add timezone conversion support
        datetime = {
            format = "%Y-%m-%d %H:%M:%S",
            -- timezone = "America/Los_Angeles",
        }
        -- TODO: Add window defaults (width [percentage, fixed width, etc])
        -- size = "%20",
    }
}

M.DATA = {}


return M
