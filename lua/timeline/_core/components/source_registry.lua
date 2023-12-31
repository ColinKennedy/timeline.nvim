local M = {}

local tabler = require("timeline._core.vim_utilities.tabler")
local file = require("timeline._core.sources.file")
local git = require("timeline._core.sources.git")

-- TODO: Add more, here
local _DEFAULTS = {
    file.Source,
    git.Source,
}
local SOURCE_TYPES = tabler.copy(_DEFAULTS)
local SOURCES = {}


function M.create_sources()
    local output = {}

    for _, source in ipairs(SOURCE_TYPES)
    do
        table.insert(output, source:new())
    end

    return output
end


return M
