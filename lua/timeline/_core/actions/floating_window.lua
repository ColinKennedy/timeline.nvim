--- A module that displays git commit details as floating windows.
---
--- This is primarily used for the Timeline Viewer.
---
--- @module 'timeline._core.actions.floating_window'
---

local M = {}


--- Create a floating window for `details`.
---
--- @source https://www.statox.fr/posts/2021/03/breaking_habits_floating_window
---
--- @param window number The window to spawn a floating window on top of.
--- @param details GitCommitDetails Pre-computed git commit data to display.
---
function M.show_git_details_under_cursor(window, details)
    local buffer = vim.api.nvim_create_buf(false, true)
    -- vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    --
    -- vim.api.nvim_set_hl(0, "TimelineNvimGitCommitAuthor", {link="String"})
    -- vim.api.nvim_set_hl(0, "TimelineNvimGitCommitEmail", {link="Text"})
    -- vim.api.nvim_set_hl(0, "TimelineNvimGitCommitDate", {link="Number"})
    -- vim.api.nvim_set_hl(0, "TimelineNvimGitCommitCommit", {link="Special"})
    -- vim.fn.matchadd("TimelineNvimGitCommitAuthor", "")
    --
    -- vim.fn.matchaddpos()
    -- print('DEBUGPRINT[1]: floating_window.lua:4: record=' .. vim.inspect(record))
    --
    -- -- Author: details._author <details._email>
    -- -- Date: details._author_date
    -- --
    -- -- details._short_stats
    -- --
    -- -- details._message
    -- --
    -- -- Commit: details._commit
    --
    -- -- self._author = data.author
    -- -- self._commit = data.commit
    -- -- self._email = data.email
    -- -- self._message = data.message
    -- -- self._notes = data.notes
    -- -- self._parents = data.parents
    -- --
    -- -- self._author_date = data.author_date
    -- -- self._commit_date = data.commit_date
    --
    -- local window = vim.fn.win_getid()
    --
    -- local floating_window = vim.api.nvim_open_win(
    --     window,
    --     false,
    --     {relative="cursor", row=0, col=0, width=30, height=3}
    -- )
end


return M
