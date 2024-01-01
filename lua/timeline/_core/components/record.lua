local constant = require("timeline._core.constant")
local tabler = require("timeline._core.vim_utilities.tabler")

local M = {}


M.Record = {}

-- TODO: Finish docstring
--- @class Record An individual entry to display in the Timeline Viewer.

--- @class RecordRange
---     This range is meant to be *inclusive* as in operations that use it
---     should consider both values and not "search" for any Record entries around
---     the Record history. Note: the start and end Record is allowed
---     to be the same Record.
--- @field 1 Record
---     The starting Record to compare / operate from.
--- @field 2 Record
---     The ending Record to compare / operate from.

function M.Record:new(data)
    local self = {}

    setmetatable(self, { __index = M.Record })

    self.get_actions = data.actions
    self.get_datetime_text = data.datetime_text
    self.get_datetime_number = data.datetime_number
    self.get_details = data.details
    self.get_icon = data.icon
    self.get_label = data.label
    self.get_record_type = data.record_type
    self.get_source_type = data.source_type

    return self
end


function M.get_selected_records(buffer)
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

    -- TODO: Make sure that this is inclusive
    return tabler.slice(records, start_line, end_line)
end


return M
