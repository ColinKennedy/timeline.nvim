-- TODO: Docstring

local M = {}

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
