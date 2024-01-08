--- A generic set of functions to make dealing with datetime objects easier.
---
--- @module 'timeline._core.git_utilities.date_mate'
---

local luatz = require("timeline._vendors.luatz")

local configuration = require("timeline._core.configuration")


local M = {}


--- Convert a UTC Unix epoch into a datetime for the selected timezone.
---
--- If no timezone is given, keep the datetime in UTC.
---
--- @param unix_epoch number
--- @return luatz.timetable # The generated object.
---
function M.get_datetime_with_timezone(unix_epoch)
    local timezone = configuration.DATA.timeline_window.datetime.timezone

    if timezone == "auto"
    then
        -- The user didn't specify a timezone. Skip it
        -- Reference: https://stackoverflow.com/a/36030419
        --
        local timezone_coefficient = tonumber(os.date("%z")) / 100
        local auto_timezone_offset = timezone_coefficient * 60 * 60

        return luatz.timetable.new_from_timestamp(unix_epoch + auto_timezone_offset)
    elseif timezone == nil
    then
        return luatz.timetable.new_from_timestamp(unix_epoch + auto_timezone_offset)
    end

    local unix_epoch_with_timezone_applied = luatz.time_in(timezone, unix_epoch)

    return luatz.timetable.new_from_timestamp(unix_epoch_with_timezone_applied)
end


return M
