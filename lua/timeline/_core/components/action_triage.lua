--- The module that finds and executes any selected Record objects.
---
--- "Selected" means different things in different Vim modes...
--- - Normal mode: The current line in the Timeline View window. It's always 1 line.
--- - Visual mode: The selection in the Timeline View window. Could be 2+ lines.
---
--- Some Action objects require a single selection and others require multiple.
--- The Action must error if the selection is invalid and exit early.
---
--- @module 'timeline._core.components.action_triage'
---

local floating_window = require("timeline._core.actions.floating_window")
local record_ = require("timeline._core.components.record")
local tabler = require("timeline._core.vim_utilities.tabler")

local M = {}


--- Get the Record data types from `records`.
---
--- @param records Records[] Parsed entries to return values for.
--- @return string[] # The unique, found Record types.
---
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


--- Ask the user to select one Record type.
---
--- This is useful when you must operate on one Record type at a time.
---
--- @param record_types string[] The unique, Record types used as input.
--- @return string # The selected Record type.
---
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
        -- TODO: Add FZF / telescope support here, for input
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


--- Get a new array of just a single Record type.
---
--- @param record_type string A unique Record to filter `records` by.
--- @param records Record[] The entries that we assume has 2+ unique types to filter by.
--- @return Record[] # The filtered entries with all types but `record_type` omitted.
---
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


-- TODO: Make this function work using window IDs, instead. Currently it
-- assumes that the selection is in the current window.
--
--- Get the current selection of a single type of Record objects, from `buffer`.
---
--- @param buffer number A 0-or-more ID indicating the buffer to query.
--- @return Record[]? # All entries of a specific Record type.
---
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


--- Find the selected start / end Record objects of `buffer`.
---
--- @param buffer number A 0-or-more ID indicating the buffer to query.
--- @return RecordRange # The two entries to consider for operations.
---
local function _get_records_range(buffer)
    local records = _get_selected_records(buffer)

    if records == nil
    then
        return {nil, nil}
    end

    return {records[1], records[#records]}
end


--- Write over `source_buffer` with the current selection from `timeline_buffer`.
---
--- Important:
---     This function assumes that the cursor is currently in the Timeline View's window.
---     TODO: It'd be nice to remove this restriction.
---
--- @param timeline_buffer number
---     A 0-or-more ID indicating the buffer that has a Record selection.
--- @param source_buffer number
---     A 0-or-more ID indicating the file-buffer to overwrite and save.
---
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


--- Open windows / data from `timeline_buffer`.
---
--- Depending on what the found Record objects are, this may spawn new windows,
--- reuse existing windows, or do other things. See the
--- `"./lua/timeline/_core/sources/*.lua"` folder for details.
---
--- Important:
---     This function assumes that the cursor is currently in the Timeline View's window.
---     TODO: It'd be nice to remove this restriction.
---
--- @param timeline_buffer number
---     A 0-or-more ID indicating the buffer that has a Record selection.
--- @param source_buffer number
---     A 0-or-more ID indicating the file-buffer to possibly change or extend.
---
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


--- Run 'diffthis' on the currently-selected Record objects from `timeline_buffer`.
---
--- Important:
---     This function assumes that the cursor is currently in the Timeline View's window.
---     TODO: It'd be nice to remove this restriction.
---
--- @param timeline_buffer number
---     A 0-or-more ID pointing to the Timeline View.
--- @param source_buffer number
---     A 0-or-more ID pointing to a paired buffer. This buffer's window might
---     have its window overwritten in the process. If there's no window containing
---     `source_buffer`, the diff action typically creates 2 new windows for the diff.
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


--- Open the details of the git commit at the current Timeline View selection.
---
--- Important:
---     Currently this function can only run on one commit at a time.
---
--- @param timeline_buffer number
---     A 0-or-more ID pointing to the Timeline View.
--- @param source_buffer number
---     A 0-or-more ID pointing to a paired buffer.
---
function M.run_show_git_action(timeline_buffer, source_buffer)
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

    floating_window.show_git_details_under_cursor(
        start_record:get_details().git_commit_details
    )
end


--- Open a debugging view for the selected Records.
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


--- Open the file at a current Record's history.
---
--- This is useful when you want to know "what does this file look like at this
--- point in time?"
---
--- Important:
---     This function assumes that the cursor is currently in the Timeline View's window.
---     TODO: It'd be nice to remove this restriction.
---
--- @param timeline_buffer number
---     A 0-or-more ID pointing to the Timeline View.
--- @param source_buffer number
---     A 0-or-more ID pointing to a paired buffer This buffer's window might
---     have its window overwritten in the process. If there's no window containing
---     `source_buffer`, the diff action typically creates 2 new windows for the diff.
---
function M.run_view_this_action(timeline_buffer, source_buffer)
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

    local caller = start_record:get_actions().view_this

    if caller == nil
    then
        vim.api.nvim_err_writeln(
            string.format('Record "%s" has no View This action.', vim.inspect(start_record))
        )

        return
    end

    caller(start_record)
end


return M
