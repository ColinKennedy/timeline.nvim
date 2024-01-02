--- A miscellaneous module for handling undo events in the Timeline Viewer.
---
--- @module 'timeline._core.components.undo_manager'
---

local backup = require("timeline._core.git_utilities.backup")
local constant = require("timeline._core.constant")

local M = {}


--- Check if `buffer` can be saved as a backup and, if so, save the backup.
---
--- This function does nothing if `buffer` is not already a file on-disk.
---
--- @param root string An absolute directory to the backup git repository.
--- @param buffer number The buffer to save, if needed.
---
function M.add_undo_redo_record_if_needed(root, buffer)
    if vim.fn.filereadable(vim.fn.bufname(buffer)) ~= 1
    then
        -- The user is working off an unsaved buffer. Don't save any history onto it.
        return
    end

    backup.backup_file(root, buffer, constant.RecordTypes.undo_redo)
end


return M
