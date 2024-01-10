--- Diff / Compare timeline.nvim's Record objects.
---
--- @module 'timeline._core.actions.differ'
---

local git_buffer = require("timeline._core.git_utilities.git_buffer")
local git_parser = require("timeline._core.git_utilities.git_parser")
local terminal = require("timeline._core.vim_utilities.terminal")

local M = {}


--- Open a diff between two commits.
---
--- @param path string
---     A git-tracked file path to gather a diff for. This path *must* be
---     a relative path to `root`.
--- @param repository string
---     The root of a git repository to search within for commits.
--- @param start_commit string
---     The first commit to diff from.
--- @param end_commit? string
---     The last commit to diff to. If no commit is given, "1 commit prior to
---     `start_commit`" is used instead.
--- @param replacement_window number?
---     If provided, this window will be replaced by a diff view. If not
---     provided, a new vertical split is used to create a diff, instead.
---
local function _open_diff_commits(
    path,
    repository,
    start_commit,
    end_commit,
    replacement_window
)
    if end_commit == nil
    then
        end_commit = start_commit .. "~"
    end

    local start_stdout = git_parser.get_commit_text(path, repository, start_commit)

    if start_stdout == nil
    then
        return
    end

    local end_stdout = git_parser.get_commit_text(path, repository, end_commit)

    if end_stdout == nil
    then
        return
    end

    if replacement_window ~= nil
    then
        vim.api.nvim_set_current_win(replacement_window)
        vim.cmd.enew()
    else
        vim.cmd.vnew()
    end

    local first_buffer = git_buffer.make_read_only_view(
        path,
        repository,
        start_commit,
        start_stdout
    )
    vim.cmd.buffer(first_buffer)
    vim.cmd.diffthis()  -- Mark the first window to diff from

    vim.cmd.vnew()
    local last_buffer = git_buffer.make_read_only_view(
        path,
        repository,
        end_commit,
        end_stdout
    )
    vim.cmd.buffer(last_buffer)
    vim.cmd.diffthis()  -- Mark this last window to diff to
end


--- Run 'diffthis' on `records`, open a summary page, and show them both in new window(s).
---
--- @param records Record[]
---     1-or-more Timeline View entries to 'diffthis'.
--- @param replacement_window number?
---     If provided, this window will be replaced by a diff view. If not
---     provided, a new vertical split is used to create a diff, instead.
---
function M.open_diff_records_and_summary(records, replacement_window)
    -- TODO: Add the summary window
    M.open_diff_records(records, replacement_window)
end


--- Run 'diffthis' on `records` and show them in new window(s).
---
--- @param records Record[]
---     1-or-more Timeline View entries to 'diffthis'.
--- @param replacement_window number?
---     If provided, this window will be replaced by a diff view. If not
---     provided, a new vertical split is used to create a diff, instead.
---
function M.open_diff_records(records, replacement_window)
    -- TODO: Add the summary window
    local start_record = records[1]

    local start_details = start_record:get_details()
    local start_commit = start_details.git_commit

    if start_commit == nil
    then
        vim.api.nvim_err_writeln("Cannot load diff. No data was found.")

        return
    end

    local end_record = records[#records]
    local end_commit = nil

    if start_record ~= end_record
    then
        end_commit = end_record:get_details().git_commit
    end

    _open_diff_commits(
        start_details.repository_path,
        start_details.repository_root,
        start_commit,
        end_commit,
        replacement_window
    )
end


return M
