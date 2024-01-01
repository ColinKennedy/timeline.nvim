local tabler = require("timeline._core.vim_utilities.tabler")
local record_ = require("timeline._core.components.record")

local M = {}


local function _get_record_types(records)
    local types = {}

    for _, record in ipairs(records)
    do
        local record_type = record:get_record_type()
        if not tabler.has_value(types, record_type)
        then
            table.insert(types, record_type)
        end
    end

    return types
end


local function _ask_for_record_type(record_types)
    -- TODO: Change this function to allow for minimal typing, like how Vim does it
    local lines = {}
    local types = {}

    for index, name in ipairs(record_types)
    do
        local lowered = name:lower()

        table.insert(lines, string.format("%s: %s", index, lowered))
        types[tostring(index)] = name
        types[lowered] = name
    end

    while true
    do
        local result = vim.fn.input(
            string.format(
                "Multiple record types detected."
                .. "\nSelect one record type to continue:\n%s\n",
                table.concat(lines, "\n")
            )
        )

        local lowered = result:lower()

        if types[lowered] ~= nil
        then
            return types[lowered]
        end
    end
end


local function _filter_records_by_type(record_type, records)
    local output = {}

    for _, record in ipairs(records)
    do
        if record:get_record_type() == record_type
        then
            table.insert(output, record)
        end
    end

    return output
end


local function _get_selected_records(buffer)
    local records = record_.get_selected_records(buffer)

    if records == nil
    then
        return nil
    end

    local record_types = _get_record_types(records)

    if #record_types > 1
    then
        local record_type = _ask_for_record_type(record_types)
        records = _filter_records_by_type(record_type, records)
    end

    return records or nil
end


local function _get_records_range(buffer)
    local records = _get_selected_records(buffer)

    if records == nil
    then
        return {nil, nil}
    end

    return {records[1], records[#records]}
end


function M.run_restore_action(timeline_buffer, source_buffer)
    local start_record, end_record = unpack(_get_records_range(timeline_buffer))

    if start_record == nil or end_record == nil
    then
        local name = vim.fn.bufname(source_buffer) or source_buffer

        vim.api.nvim_err_writeln(
            string.format('Buffer "%s" has no records. Cannot diff.', name)
        )

        return
    end

    if start_record ~= end_record
    then
        vim.api.nvim_err_writeln(
            string.format("Please select only one record at a time to restore.")
        )

        return
    end

    start_record.actions.restore(start_record)
end


function M.run_open_action(timeline_buffer, source_buffer)
    local records = _get_selected_records(timeline_buffer)

    if records == nil
    then
        local name = vim.fn.bufname(source_buffer) or source_buffer

        vim.api.nvim_err_writeln(
            string.format('Buffer "%s" has no records. Cannot open.', name)
        )

        return
    end

    local record = records[1]
    local caller = record:get_actions().open

    if caller == nil
    then
        vim.api.nvim_err_writeln(
            string.format('Record "%s" has no open action.', vim.inspect(record))
        )

        return
    end

    caller(records)
end


function M.run_show_manifest_action(timeline_buffer, source_buffer)
    local start_record, end_record = unpack(_get_records_range(timeline_buffer))

    if start_record == nil or end_record == nil
    then
        local name = vim.fn.bufname(source_buffer) or source_buffer

        vim.api.nvim_err_writeln(
            string.format(
                'Buffer "%s" has no records. Cannot show the manifest.',
                name
            )
        )

        return
    end

    records[1].actions.open(records[#records])
end


--- Run 'diffthis' on the currently-selected Record objects from `timeline_buffer`.
---
--- Important:
---     This function assumes that the cursor is currently in the Timeline View's window.
---     TODO: It'd be nice to remove this restriction.
---
--- @param timeline_buffer number
---     A 0-or-more ID pointing to the Timeline View.
--- @param source_buffer number
---     A 0-or-more ID pointing to a paired buffer.
---
function M.run_show_diff_action(timeline_buffer, source_buffer)
    local records = _get_selected_records(timeline_buffer)

    if records == nil
    then
        local name = vim.fn.bufname(source_buffer) or source_buffer

        vim.api.nvim_err_writeln(
            string.format('Buffer "%s" has no records. Cannot diff.', name)
        )

        return
    end

    local record = records[1]
    local caller = record:get_actions().show_diff

    if caller == nil
    then
        vim.api.nvim_err_writeln(
            string.format('Record "%s" has no diff action.', vim.inspect(record))
        )

        return
    end

    caller(records)
end


return M
