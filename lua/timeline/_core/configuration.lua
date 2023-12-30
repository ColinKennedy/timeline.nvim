local M = {}

M._DEFAULTS = {
    mappings = {
        restore = "u",
        show_default = "o",
        show_details = "de",
        show_diff = "di",
        show_summary = "s",
    },
    repository_paths = {"~/.vim_custom_backups"},
    sources = {
        file = { icon = "" },
        git = { icon = "󰜘" },
    },
    -- TODO: Add window defaults (width [percentage, fixed width, etc])
}

M.DATA = {}

return M
