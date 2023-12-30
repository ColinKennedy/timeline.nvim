--- The entry point for displaying a timeline.
---
--- @module 'timeline.viewer'
---

local configuration = require("timeline._core.configuration")
local constant = require("timeline._core.constant")
local request = require("timeline._core.request")
local source_registry = require("timeline._core.source_registry")
local tabler = require("timeline._core.utilities.tabler")

local M = {}


local function _add_mappings(buffer)
    configuration.DATA.mappings.restore
    restore = "u",
    show_default = "o",
    show_details = "de",
    show_diff = "di",
    show_summary = "s",
end


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
    local path = vim.fn.expand("%:p")
    M.view(path)
end


function M.view(path)
    local buffer, window = unpack(_create_viewer())
    local height = vim.api.nvim_win_get_height(window)
    local offset = 0
    local payload = request.Request:new(path, height, offset)

    local records = {}

    for _, source in ipairs(source_registry.SOURCES)
    do
        tabler.extend(source:collect(payload, configuration.DATA), records)
    end

    _apply_records_to_viewer(records, buffer)
    _add_mappings(buffer)
end

return M
