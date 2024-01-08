--- A module that displays git commit details as floating windows.
---
--- This is primarily used for the Timeline Viewer.
---
--- @module 'timeline._core.actions.floating_window'
---

local M = {}


--- Find the line that has the most characters from `lines`.
---
--- @param lines string[] Some text to check.
--- @return number A 0-or-more value indicating the maximum length.
---
local function _get_maximum_length(lines)
    local maximum = 0

    for _, text in ipairs(lines)
    do
        local count = #text

        if count > maximum
        then
            maximum = count
        end
    end

    return maximum
end


--- Create a floating window for `details`.
---
--- @source https://www.statox.fr/posts/2021/03/breaking_habits_floating_window
---
--- @param window number The window to spawn a floating window on top of.
--- @param details GitCommitDetails Pre-computed git commit data to display.
---
function M.show_git_details_under_cursor(details)
    local author = details:get_author()
    local commit = details:get_commit()

    -- TODO: Fix cyclic loop, later
    local configuration = require("timeline._core.configuration")
    local datetime = details:get_author_date():strftime(
        configuration.DATA.timeline_window.datetime.format
    )
    local email = details:get_email()

    -- TODO: Make this less gross
    local lines = {}
    table.insert(lines, string.format("Author: %s <%s>", author, email))
    table.insert(lines, string.format("Date: %s", datetime))
    table.insert(lines, "")
    table.insert(lines, message)
    table.insert(lines, string.format("Commit: %s", commit))

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)

    vim.fn.matchadd("TimelineNvimGitCommitAuthor", author)
    vim.fn.matchadd("TimelineNvimGitCommitCommit", commit)
    vim.fn.matchadd("TimelineNvimGitCommitDate", datetime)
    vim.fn.matchadd("TimelineNvimGitCommitEmail", email)

    local width = _get_maximum_length(lines)
    local padding = 5  -- TODO: Figure out if this is needed or just a personal issue
    local floating_window = vim.api.nvim_open_win(
        buffer,
        false,
        {relative="cursor", row=0, col=0, width=width + padding, height=#lines}
    )
end


return M
