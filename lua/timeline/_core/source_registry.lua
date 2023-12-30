local M = {}

local tabler = require("timeline._core.utilities.tabler")
local file = require("timeline._core.sources.file")
local git = require("timeline._core.sources.git")

-- TODO: Add more, here
local _DEFAULTS = {
    file.Source,
    -- git.Source,
}
local SOURCES = tabler.copy(_DEFAULTS)


function M.get_all_sources()
    local output = {}

    for _, source in ipairs(SOURCES)
    do
        table.insert(output, source:new())
    end

    return output
end


return M
