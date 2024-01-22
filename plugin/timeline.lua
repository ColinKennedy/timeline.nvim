-- Add syntax highlight groups for floating windows in the Timeline Viewer.
vim.api.nvim_set_hl(0, "TimelineNvimGitCommitAuthor", {default=true, link="String"})
vim.api.nvim_set_hl(0, "TimelineNvimGitCommitCommit", {default=true, link="Special"})
vim.api.nvim_set_hl(0, "TimelineNvimGitCommitDate", {default=true, link="Number"})
vim.api.nvim_set_hl(0, "TimelineNvimGitCommitEmail", {default=true, link="Text"})

-- Add convenience commands
vim.api.nvim_create_user_command(
    "TimelineOpenCurrent",
    function()
        require("timeline.viewer").view_current()
    end,
    {
        desc="Open the timeline data for the current buffer, if any data.",
        nargs=0,
    }
)

vim.api.nvim_create_user_command(
    "TimelineOpenWindow",
    function(window)
        require("timeline.viewer").view_window()
    end,
    {
        desc="Open the timeline data for some window ID (use vim.fn.win_getid()).",
        nargs=1,
    }
)
