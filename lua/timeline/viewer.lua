--- The entry point for displaying a timeline.
---
--- @module 'timeline.viewer'
---

local configuration = require("timeline._core.configuration")
local constant = require("timeline._core.constant")
local keymap_manager = require("timeline._core.components.keymap_manager")
local request = require("timeline._core.components.request")
local source_registry = require("timeline._core.components.source_registry")
local tabler = require("timeline._core.vim_utilities.tabler")

local M = {}


local function _apply_records_to_viewer(records, buffer)
    local modifiable = vim.api.nvim_buf_get_option(buffer, "modifiable")
    vim.api.nvim_buf_set_option(buffer, "modifiable", true)

    local lines = {}

    for _, record in ipairs(records)
    do
        local label = record:get_label()
        local datetime = record:get_datetime()
        local icon = record:get_icon()

        if icon ~= nil
        then
            table.insert(lines, string.format("%s %s - %s", icon, label, datetime))
        else
            table.insert(lines, string.format("%s - %s", label, datetime))
        end
    end

    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buffer, "modifiable", modifiable)
    vim.api.nvim_buf_set_var(buffer, constant.BUFFER_RECORDS_VARIABLE, records)
end


local function _create_viewer()
    vim.cmd.vsplit()
    vim.cmd.enew()

    local buffer = vim.fn.bufnr("%")

    vim.api.nvim_buf_set_option(buffer, "filetype", constant.VIEWER_FILE_TYPE)
    vim.api.nvim_buf_set_option(buffer, "modifiable", false)

    return {buffer, vim.fn.win_getid()}
end


function M.view_current()
    local buffer = vim.fn.bufnr()

    M.view_buffer(buffer)
end


function M.view_buffer(source_buffer)
    local path = vim.api.nvim_buf_get_name(source_buffer)

    if path == ""
    then
        vim.api.nvim_err_writeln(
            string.format('Buffer "%s" must have a file path on-disk.', source_buffer)
        )

        return
    end

    local timeline_buffer, timeline_window = unpack(_create_viewer())
    local height = vim.api.nvim_win_get_height(timeline_window)
    local offset = 0
    local payload = request.Request:new(path, height, offset)

    local records = {}

    for _, source in ipairs(source_registry.SOURCES)
    do
        tabler.extend(source:collect(payload, configuration.DATA), records)
    end

    _apply_records_to_viewer(records, timeline_buffer)
    keymap_manager.initialize_buffer_mappings(timeline_buffer, source_buffer)
end

return M
