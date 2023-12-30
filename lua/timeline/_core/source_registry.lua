local M = {}

local tabler = require("timeline._core.utilities.tabler")
local file = require("timeline._core.sources.file")
local git = require("timeline._core.sources.git")

-- TODO: Add more, here
local _DEFAULTS = {file, git}
local SOURCES = tabler.copy(_DEFAULTS)

function M.get_all_sources()
    return SOURCES
end


return M
