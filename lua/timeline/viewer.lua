--- The entry point for displaying a timeline.
---
--- @module 'timeline.viewer'
---

local configuration = require("timeline._core.configuration")
local constant = require("timeline._core.constant")
local floating_window = require("timeline._core.actions.floating_window")
local keymap_manager = require("timeline._core.components.keymap_manager")
local request = require("timeline._core.components.request")
local source_registry = require("timeline._core.components.source_registry")
local tabler = require("timeline._core.vim_utilities.tabler")
local virtual_text = require("timeline._core.components.virtual_text")

local M = {}


--- Place `records` onto `buffer`.
---
--- @param records Record[] The data to display in `buffer`.
--- @param buffer number A 0-or-more to be replaced by `records`.
---
local function _apply_records_to_viewer(records, buffer)
    local modifiable = vim.api.nvim_buf_get_option(buffer, "modifiable")
    vim.api.nvim_buf_set_option(buffer, "modifiable", true)

    local lines = {}

    for _, record in ipairs(records)
    do
        local label = record:get_label()
        local icon = record:get_icon()

        if icon ~= nil
        then
            table.insert(lines, string.format("%s %s", icon, label))
        else
            table.insert(lines, label)
        end
    end

    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buffer, "modifiable", modifiable)
    vim.api.nvim_buf_set_var(buffer, constant.BUFFER_RECORDS_VARIABLE, records)
end


--- Make a new Timeline View.
---
--- TODO Define BufferWindowPair
--- @return BufferWindowPair # The Timeline View buffer and its window.
---
local function _create_viewer()
    vim.cmd.vsplit()
    vim.cmd.enew()

    vim.cmd("vertical resize " .. configuration.DATA.timeline_window.size)

    local buffer = vim.fn.bufnr("%")

    vim.api.nvim_buf_set_option(buffer, "filetype", constant.VIEWER_FILE_TYPE)
    vim.api.nvim_buf_set_option(buffer, "modifiable", false)

    return {buffer, vim.fn.win_getid()}
end


--- Load a Timeline View for the current window.
function M.view_current()
    M.view_window(vim.fn.win_getid())
end


--- Load a Timeline View for `source_window`.
---
--- @param source_window number A 0-or-more value of some buffer to display.
---
function M.view_window(source_window)
    if source_window == 0
    then
        -- Later function calls require an explicit window ID so grab it, now
        source_window = vim.fn.win_getid()
    end

    local source_buffer = vim.api.nvim_win_get_buf(source_window)
    local path = vim.api.nvim_buf_get_name(source_buffer)

    if path == ""
    then
        vim.api.nvim_err_writeln(
            string.format('Buffer "%s" must be a file path on-disk.', source_buffer)
        )

        return
    end

    local timeline_buffer, timeline_window = unpack(_create_viewer())
    local height = vim.api.nvim_win_get_height(timeline_window)
    local offset = 0
    local payload = request.Request:new(path, height * 2, offset, source_window)

    local records = {}

    for _, source in ipairs(source_registry.SOURCES)
    do
        tabler.extend(records, source:collect(payload))
    end

    -- Interleave the records by their date
    table.sort(
        records,
        function(left, right)
            return left:get_datetime():timestamp() > right:get_datetime():timestamp()
        end
    )

    -- Create a new view and display the records
    _apply_records_to_viewer(records, timeline_buffer)
    virtual_text.apply_timeline_auto_commands(timeline_buffer)
    floating_window.apply_timeline_auto_commands(timeline_buffer)

    if configuration.DATA.timeline_window.datetime.relative_virtual_text
    then
        virtual_text.apply_datetime_updater(timeline_buffer)
    end

    keymap_manager.initialize_buffer_mappings(timeline_buffer, source_buffer)
end


return M
