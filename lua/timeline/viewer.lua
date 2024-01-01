--- The entry point for displaying a timeline.
---
--- @module 'timeline.viewer'
---

local configuration = require("timeline._core.configuration")
local constant = require("timeline._core.constant")
local keymap_manager = require("timeline._core.components.keymap_manager")
local record_ = require("timeline._core.components.record")
local request = require("timeline._core.components.request")
local source_registry = require("timeline._core.components.source_registry")
local tabler = require("timeline._core.vim_utilities.tabler")

local M = {}


local _VIRTUAL_TEXT_GROUP = vim.api.nvim_create_augroup(
    "TimelineViewVirtualTextGroup", { clear = true }
)
local _VIRTUAL_TEXT_NAMESPACE = vim.api.nvim_create_namespace(
    "TimelineViewVirtualTextNamespace"
)


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


-- TODO: docstring
local function _add_datetime_virtual_text(buffer, namespace)
    -- TODO: Figure out how to call this with an explicit window ID
    local records = record_.get_selected_records() or {
        vim.api.nvim_buf_get_var(
            buffer,
            constant.BUFFER_RECORDS_VARIABLE
        )[vim.fn.line(".")],
    }

    if records == nil
    then
        return
    end

    local line = vim.fn.line(".") - 1  -- Vim line is 1-or-more but we need 0-or-more

    local start_column = 0
    local start_line = line
    local text_to_display = {}

    for _, record in ipairs(records)
    do
        table.insert(text_to_display, record:get_datetime_text())
    end

    -- TODO: Figure out how to get comment colors to work
    vim.api.nvim_buf_set_extmark(
        buffer,
        namespace,
        start_line,
        start_column,
        {
            virt_text = {text_to_display},
            hl_group = "Comment",
        }
    )
end


-- TODO: docstring
local function _apply_timeline_auto_commands(buffer)
    vim.api.nvim_create_autocmd(
        {"CursorMoved", "CursorMovedI"},
        {
            group = _VIRTUAL_TEXT_GROUP,
            callback = function()
                vim.api.nvim_buf_clear_namespace(buffer, _VIRTUAL_TEXT_NAMESPACE, 0, -1)
                _add_datetime_virtual_text(buffer, _VIRTUAL_TEXT_NAMESPACE)
            end,
            buffer = buffer,
        }
    )
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
    local payload = request.Request:new(path, height, offset, source_window)

    local records = {}

    for _, source in ipairs(source_registry.SOURCES)
    do
        tabler.extend(source:collect(payload), records)
    end

    -- Interleave the records by their date
    table.sort(
        records,
        function(left, right)
            return left:get_datetime_number() > right:get_datetime_number()
        end
    )

    -- Create a new view and display the records
    _apply_records_to_viewer(records, timeline_buffer)
    _apply_timeline_auto_commands(timeline_buffer)
    keymap_manager.initialize_buffer_mappings(timeline_buffer, source_buffer)
end


return M
