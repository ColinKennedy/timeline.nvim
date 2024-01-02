--- The main module to setup Timline Viewer sources.
---
--- A "Source" is "a means of finding data to add into the Timeline Viewer".
--- Just about anything is allowed as a Source, as long as it implements the
--- right methods.
---

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
local SOURCES = {} -- This will be populated during `require("timeline").setup()`


--- @return Source[] # Instantiate new Source objects based on the registry.
function M.create_sources()
    local output = {}

    for _, source in ipairs(SOURCE_TYPES)
    do
        table.insert(output, source:new())
    end

    return output
end


return M
