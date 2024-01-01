local luatz = require("timeline._vendors.luatz")

local configuration = require("timeline._core.configuration")


local M = {}


function M.get_datetime_with_timezone(unix_epoch)
    local unix_epoch_with_timezone_applied = luatz.time_in(
        configuration.DATA.timeline_window.datetime.timezone,
        unix_epoch
    )

    return luatz.timetable.new_from_timestamp(unix_epoch_with_timezone_applied)
end


return M
