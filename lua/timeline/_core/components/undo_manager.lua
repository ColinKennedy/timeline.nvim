local backup = require("timeline._core.git_utilities.backup")
local constant = require("timeline._core.constant")

local M = {}


function M.add_undo_redo_record_if_needed(root, buffer)
    if vim.fn.filereadable(vim.fn.bufname(buffer)) ~= 1
    then
        -- The user is working off an unsaved buffer. Don't save any history onto it
        return
    end

    backup.backup_file(root, buffer, constant.RecordTypes.undo_redo)
end


return M
