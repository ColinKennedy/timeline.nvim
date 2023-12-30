local M = {}

M.Record = {}


function M.Record:new(data)
    local self = {}

    setmetatable(self, { __index = M.Record })

    self.get_datetime = data.datetime
    self.get_label = data.label
    self.get_icon = data.icon
    self.get_source = data.source
    self.get_type = data.type
    self.get_id = data.get_id

    return self
end


return M
