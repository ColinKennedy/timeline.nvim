--- A module that's dedicated to handling the virtual text in the Timeline Viewer.
---
--- @module 'timeline._core.components.virtual_text'
---

local constant = require("timeline._core.constant")
local record_ = require("timeline._core.components.record")

local M = {}

local _VIRTUAL_TEXT_GROUP = vim.api.nvim_create_augroup(
    "TimelineViewVirtualTextGroup", { clear = true }
)
local _VIRTUAL_TEXT_NAMESPACE = vim.api.nvim_create_namespace(
    "TimelineViewVirtualTextNamespace"
)


--- Show virtual text at the current cursor line in `buffer`.
---
--- @param buffer number A 0-or-more ID to some buffer.
--- @param namespace number 1-or-more ID used for drawing the virtual text.
---
local function _add_datetime_virtual_text(buffer, namespace)
    -- TODO: Figure out how to call this with an explicit window ID
    local records = record_.get_selected_records(buffer) or {
        vim.api.nvim_buf_get_var(
            buffer,
            constant.BUFFER_RECORDS_VARIABLE
        )[vim.fn.line(".")],
    }

    if records == nil or vim.tbl_isempty(records)
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


--- Update virtual text whenever the cursor changes in `buffer`.
---
--- @param buffer number A 0-or-more ID to some buffer.
---
function M.apply_timeline_auto_commands(buffer)
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


return M
