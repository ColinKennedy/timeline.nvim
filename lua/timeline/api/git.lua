--- All helper git calls that users can run in their personal Neovim configurations.
---
--- @module 'timeline.api.git'
---

local M = {}

--- Create a full message. e.g. "my_repo/master: Updated file: /path/to/file.py".
---
--- @param data FileSaveMessageData
---     Packed data used to decide the commit message when there is a file_save.
--- @return string
---     The created message.
---
function M.get_default_file_save_message(data)
    local directory = vim.fn.fnamemodify(data.source_path, ":p:h")
    local summary = M.get_summary(directory)

    local output = ""

    if summary then
        output = summary .. ": "
    end

    local file_name = vim.fn.fnamemodify(data.source_path, ":t")

    return output .. "Updated file: " .. file_name
end


--- Get a git repository + branch summary message, if any.
---
--- @param path string A path on-disk that was recently saved.
--- @return string? # The created message.
---
function M.get_summary(path)
    local git_parser = require("timeline._core.git_utilities.git_parser")
    local directory = git_parser.get_repository_root(path)

    if not directory then
        return nil
    end

    local repository_directory = vim.fn.fnamemodify(directory, ":t")
    local output = repository_directory

    local branch_or_head = git_parser.get_head(directory)

    if not branch_or_head then
        return output
    end

    return output .. "/" .. branch_or_head
end

return M
