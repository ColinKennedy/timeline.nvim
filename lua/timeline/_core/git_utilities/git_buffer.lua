--- A module for creating read-only buffers from, "git-related" data.
---
--- @module 'timeline._core.git_utilities.git_buffer'
---

local M = {}

local _GROUP = vim.api.nvim_create_augroup("TimelineGitBufferGroup", { clear = true })


--- Load a `path` at `repository`'s `commit` into a new window.
---
--- Important:
---     The current buffer's contents will be replaced by this function.
---
--- @param path string A file path in the git repository to load into a window.
--- @param repository string The root directory to some git repository.
--- @param commit string A git repository commit ID to load `path` from.
--- @param text string[] The text to populate the buffer.
--- @return number # A 1-or-more value for the ID of the newly-created buffer.
---
function M.make_read_only_view(path, repository, commit, text)
    local buffer = vim.api.nvim_create_buf(false, true)

    -- This file name is a simple URI, since it's a snapshot in time and not a real file
    -- TODO: How do I open a buffer with syntax highlighting while still expressing that it's read-only?
    vim.cmd(string.format("file git_commit:%s:%s:%s", repository, commit, path))

    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, text)
    vim.api.nvim_buf_set_option(buffer, "modifiable", false)
    local window = vim.fn.win_getid()

    -- When the window is closed, close the buffer so that it can be used again, if needed
    vim.api.nvim_create_autocmd(
        "WinClosed",
        {
            callback = function()
                if not vim.api.nvim_win_is_valid(window)
                then
                    return
                end

                vim.cmd("bdelete! " .. buffer)
            end,
            buffer = buffer,
            group = _GROUP,
        }
    )

    return buffer
end


return M
