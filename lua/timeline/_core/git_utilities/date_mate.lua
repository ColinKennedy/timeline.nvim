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
    if configuration.DATA.timeline_window.datetime.timezone == nil
    then
        -- The user didn't specify a timezone. Skip it
        return luatz.timetable.new_from_timestamp(unix_epoch)
    end

    local unix_epoch_with_timezone_applied = luatz.time_in(
        configuration.DATA.timeline_window.datetime.timezone,
        unix_epoch
    )

    return luatz.timetable.new_from_timestamp(unix_epoch_with_timezone_applied)
end


return M
