local constant = require("timeline._core.constant")
local tabler = require("timeline._core.vim_utilities.tabler")

local M = {}


-- TODO: Remove this function?
local function _find_next_record_of_same_type(records, start_index)
    -- TODO: is this for-loop inclusive on the end? Check
    local record = records[start_index]
    local expected = record:get_record_type()

    for index = start_line + 1, #records
    do
        if records[index]:get_record_type() == expected
        then
            return index
        end
    end

    return nil
end


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

    return nil
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
    local start_line = vim.fn.getpos("v")[2]
    local end_line = vim.fn.getpos(".")[2]

    local success, records = pcall(
        vim.api.nvim_buf_get_var,
        buffer,
        constant.BUFFER_RECORDS_VARIABLE
    )

    if not success
    then
        return nil
    end

    if records == nil
    then
        return nil
    end

    -- TODO: Remove later
    -- if start_line == end_line
    -- then
    --     end_line = _find_next_record_of_same_type(records, start_line)
    -- end

    -- TODO: Make sure that this is inclusive
    records = tabler.slice(records, start_line, end_line)
    local record_types = _get_record_types(records)

    if #record_types > 1
    then
        record_type = _ask_for_record_type(record_types)
        records = _filter_records_by_type(record_type, records)
    end

    return records or nil
end


function _get_records_range(buffer)
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

    local record = records[1]
    record.actions.restore(record)
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

    local caller = records[1]:get_actions().open

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


function M.run_show_diff_action(timeline_buffer, source_buffer)
    print("doing diff!")
end


return M
