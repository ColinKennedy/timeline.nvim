local constant = require("timeline._core.constant")
local tabler = require("timeline._core.vim_utilities.tabler")

local M = {}


M.Record = {}

--- @class Record An individual entry to display in the Timeline Viewer.

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
