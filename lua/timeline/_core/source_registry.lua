local M = {}

local file = require("timeline._core.sources.file")
local git = require("timeline._core.sources.git")
-- TODO: Add more, here
local _DEFAULTS = {file, git}
local SOURCES = vim.tbl_deep_extend("force", {}, _DEFAULTS)

function M.get_all_sources()
    return SOURCES
end


return M
