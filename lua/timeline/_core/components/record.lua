local M = {}

M.Record = {}


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


return M
