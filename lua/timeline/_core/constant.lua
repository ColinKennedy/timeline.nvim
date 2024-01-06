--- Simple, meaningful variables to use internally in timeline.nvim.
---
--- @module 'timeline._core.constant'
---

local M = {}


M.BUFFER_RECORDS_VARIABLE = "_timeline_records"
M.RecordTypes = {
    file_save = "file_save",
    git_commit = "git_commit",
    restore = "restore",
    undo_redo = "undo_redo",
}
M.SourceTypes = {
    file = "file",
    git = "git",
}
M.VIEWER_FILE_TYPE = "timeline_viewer"

-- TODO: Add docstring for this
M.GIT_DETAILS_FORMAT = "git show --no-patch --format=%H%n%aN%n%aE%n%at%n%ct%n%P%n%D%n%N%n%Bunique-timeline.nvim-ending"
M.GIT_DETAILS_LINE_ENDER = "unique-timeline.nvim-ending"


return M
