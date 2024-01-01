--- The main Timeline public API module.
---
--- @module 'timeline'
---

local backup = require("timeline._core.git_utilities.backup")
local configuration = require("timeline._core.configuration")
local constant = require("timeline._core.constant")
local debounce = require("timeline._core.vim_utilities.debounce")
local source_registry = require("timeline._core.components.source_registry")
local undo_manager = require("timeline._core.components.undo_manager")

local M = {}


--- Ensure `data` is correctly authored
---
--- @param data TimelineConfiguration User-provided settings to check.
--- @return boolean # If the data is valid, return `true`. Otherwise fail with a message.
---
local function _validate_data(data)
    local paths = data.source_repository_paths

    if vim.tbl_isempty(paths)
    then
        vim.api.nvim_err_writeln('"source_repository_paths" key cannot be empty.')

        return false
    end

    local resolved_paths = {}

    for _, path in ipairs(paths)
    do
        table.insert(resolved_paths, vim.fn.expand(path))
    end

    data.source_repository_paths = resolved_paths

    -- TODO: Check the other keys and stuff

    return true
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


--- Initialize mappings that persist through the Neovim session.
---
--- @param root string The git repository where file history / undos / etc are saved.
---
local function _setup_global_mappings(root)
    local milliseconds = 300
    local debounced = debounce.debounce_trailing(
        undo_manager.add_undo_redo_record_if_needed,
        milliseconds
    )

    vim.keymap.set(
        "n",
        "u",
        function()
            debounced(root, vim.fn.bufnr())

            return "u"
        end,
        { desc = "[u]ndo and send a backup to timeline.nvim.", expr = true }
    )
    vim.keymap.set(
        "n",
        "U",
        function()
            debounced(root, vim.fn.bufnr())

            return "U"
        end,
        { desc = "[u]ndo and send a backup to timeline.nvim.", expr = true }
    )
    vim.keymap.set(
        "n",
        "<C-r>",
        function()
            debounced(root, vim.fn.bufnr())

            return "<C-r>"
        end,
        { desc = "[r]edo and send a backup to timeline.nvim.", expr = true }
    )
end

--- Initialize this plugin so it can run
---
--- @param data TimelineConfiguration The settings which control timeline.nvim.
---
function M.setup(data)
    _setup_configuration(data)

    if configuration.DATA.records[constant.RecordTypes.undo_redo].enabled
    then
        _setup_global_mappings(configuration.DATA.backup_repository_path)
    end

    backup.setup(configuration.DATA.backup_repository_path)
end


return M
