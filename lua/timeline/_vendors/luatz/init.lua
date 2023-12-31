local _M = {
	gettime = require "timeline._vendors.luatz.gettime";
	parse = require "timeline._vendors.luatz.parse";
	strftime = require "timeline._vendors.luatz.strftime";
	timetable = require "timeline._vendors.luatz.timetable";
	tzcache = require "timeline._vendors.luatz.tzcache";
}

--- Top-level aliases for common functions

_M.time = _M.gettime.gettime
_M.get_tz = _M.tzcache.get_tz

--- Handy functions

_M.time_in = function(tz, now)
	return _M.get_tz(tz):localize(now)
end

_M.now = function()
	local ts = _M.gettime.gettime()
	return _M.timetable.new_from_timestamp(ts)
end

--- C-like functions

_M.gmtime = function(ts)
	return _M.timetable.new_from_timestamp(ts)
end

_M.localtime = function(ts)
	ts = _M.time_in(nil, ts)
	return _M.gmtime(ts)
end

_M.ctime = function(ts)
	return _M.strftime.asctime(_M.localtime(ts))
end

return _M
