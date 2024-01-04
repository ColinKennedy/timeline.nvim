--- A module that's dedicated to handling the virtual text in the Timeline Viewer.
---
--- @module 'timeline._core.components.virtual_text'
---

local configuration = require("timeline._core.configuration")
local constant = require("timeline._core.constant")
local luatz = require("timeline._vendors.luatz")
local record_ = require("timeline._core.components.record")

local M = {}

local _VIRTUAL_TEXT_GROUP = vim.api.nvim_create_augroup(
    "TimelineViewVirtualTextGroup", { clear = true }
)
local _VIRTUAL_TEXT_NAMESPACE = vim.api.nvim_create_namespace(
    "TimelineViewVirtualTextNamespace"
)


--- Convert `seconds` to a "fuzzy" / "human-readable" datetime.
---
--- @param seconds number A 0-or-more value to convert.
--- @return string # "2 days ago", "3 hours ago", etc.
---
local function _get_relative_text(seconds)
    denominations = {
        [31536000] = "year",
        [604800] = "week",
        [86400] = "day",
        [3600] = "hour",
        [60] = "minute",
    }

    local order = {31536000, 604800, 86400, 3600, 60}

    for _, value in ipairs(order)
    do
        if seconds >= value
        then
            local label = denominations[value]

            if seconds >= (value * 2)
            then
                label = label .. "s"  -- pluralize the text
            end

            return string.format("%s %s ago", math.floor(seconds / value), label)
        end
    end

    return string.format("%s seconds ago", seconds)
end


--- Recommend a datetime to display as part of virtual text.
---
--- @param records Records[]
---     The date to parse for datetime objects.
--- @param relative boolean
---     If `false`, the text is shown in an absolute datetime. If `true`, it
---     will display in a "human readable" text like "3 minutes ago".
--- @return string[]
---     Each datetime to display for `records`. One-string-per-record.
---
local function _get_datetime_display_text(records, relative)
    local output = {}

    if relative
    then
        local now = luatz.now()

        for _, record in ipairs(records)
        do
            local datetime = record:get_datetime()
            local seconds_apart = now - datetime
            local text = _get_relative_text(seconds_apart)

            table.insert(output, text)
        end

        return output
    end

    for _, record in ipairs(records)
    do
        local datetime = record:get_datetime()
        local text = datetime:strftime(
            configuration.DATA.timeline_window.datetime.format
        )

        table.insert(text_to_display, text)
    end

    return output
end


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

    local text_to_display = _get_datetime_display_text(
        records,
        configuration.DATA.timeline_window.datetime.relative_virtual_text
    )

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
