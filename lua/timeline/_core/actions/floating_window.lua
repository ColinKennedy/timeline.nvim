--- A module that displays git commit details as floating windows.
---
--- This is primarily used for the Timeline Viewer.
---
--- @module 'timeline._core.actions.floating_window'
---

local M = {}

local _FLOATING_WINDOW_GROUP = vim.api.nvim_create_augroup(
    "TimelineViewFloatingWindowGroup", { clear = true }
)
local _GIT_DETAILS_WINDOW_IDENTIFIER = nil


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


--- Apply auto-commands to the Timeline Viewer buffer.
---
--- This floating window is intended to only ever be open once at any time.
--- These auto-commands ensure that is is always the case.
---
--- @param buffer number A 0-or-more value indicating Timeline Viewer.
---
function M.apply_timeline_auto_commands(buffer)
    vim.api.nvim_create_autocmd(
        {"BufDelete"},
        {
            buffer = buffer,
            callback = M.close_git_details_window_if_needed,
            group = _FLOATING_WINDOW_GROUP,
        }
    )

    vim.api.nvim_create_autocmd(
        {"CursorMoved", "CursorMovedI", "WinClosed", "WinLeave"},
        {
            buffer = buffer,
            callback = function()
                -- TODO: If no more windows are open that contain buffer, close it
                M.close_git_details_window_if_needed()
            end,
            group = _FLOATING_WINDOW_GROUP,
        }
    )
end


--- If the window is open, close it.
---
--- This floating window is intended to only ever be open once at any time.
---
function M.close_git_details_window_if_needed()
    if _GIT_DETAILS_WINDOW_IDENTIFIER ~= nil
    then
        vim.api.nvim_win_close(_GIT_DETAILS_WINDOW_IDENTIFIER, true)
        _GIT_DETAILS_WINDOW_IDENTIFIER = nil
    end
end


--- Create a floating window for `details`.
---
--- @source https://www.statox.fr/posts/2021/03/breaking_habits_floating_window
---
--- @param window number The window to spawn a floating window on top of.
--- @param details GitCommitDetails Pre-computed git commit data to display.
---
function M.show_git_details_under_cursor(details)
    M.close_git_details_window_if_needed()

    local author = details:get_author()
    local commit = details:get_commit()
    local message = details:get_message()

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

    if message ~= nil and message ~= ""
    then
        table.insert(lines, "")
        table.insert(lines, message)
    end

    table.insert(lines, "")

    table.insert(lines, string.format("Commit: %s", commit))

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)

    local original_buffer = vim.fn.bufnr()
    vim.cmd("buffer " .. buffer)
    vim.cmd.syntax(string.format("match TimelineNvimGitCommitAuthor /%s/", author))
    vim.cmd.syntax(string.format("match TimelineNvimGitCommitCommit /%s/", commit))
    vim.cmd.syntax(string.format("match TimelineNvimGitCommitDate /%s/", datetime))
    vim.cmd.syntax(string.format("match TimelineNvimGitCommitEmail /%s/", email))
    vim.cmd("buffer " .. original_buffer)

    local width = _get_maximum_length(lines)
    local padding = 1  -- TODO: Figure out if this is needed or just a personal issue
    local floating_window = vim.api.nvim_open_win(
        buffer,
        false,
        {
            border="double",
            relative="cursor",
            row=0,
            col=0,
            width=width + padding,
            height=#lines,
        }
    )

    vim.api.nvim_buf_set_option(buffer, "modifiable", false)
    vim.api.nvim_win_set_option(floating_window, "signcolumn", "no")
    vim.api.nvim_win_set_option(floating_window, "number", false)
    vim.api.nvim_win_set_option(floating_window, "relativenumber", false)

    _GIT_DETAILS_WINDOW_IDENTIFIER = floating_window
end


return M
