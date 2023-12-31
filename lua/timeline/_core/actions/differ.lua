local terminal = require("timeline._core.vim_utilities.terminal")

local M = {}

local _TIMELINE_DIFF_GROUP = vim.api.nvim_create_augroup(
    "TimelineDifferAutoGroup", { clear = true }
)

local function _make_window(path, repository, commit, text)
    -- This file name is a simple URI, since it's a snapshot in time and not a real file
    vim.cmd(string.format("file git_commit:%s:%s:%s", path, repository, commit))

    local buffer = vim.fn.bufnr()
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, text)
    local window = vim.fn.win_getid()

    -- When the window is closed, close the buffer so that it can be used again, if needed
    local cursor_moved = vim.api.nvim_create_autocmd(
        "WinClosed",
        {
            group = group,
            callback = function()
                if not vim.api.nvim_win_is_valid(window)
                then
                    return
                end

                vim.cmd("bdelete! " .. buffer)
            end,
            buffer = buffer,
        }
    )
end


function M.open_diff_records_and_summary(records, replacement_window)
    -- TODO: Add the summary
    local start_record = records[1]

    local start_details = start_record:get_details()
    local start_commit = start_details.git_commit

    if start_commit == nil
    then
        vim.api.nvim_err_writeln("Cannot load diff. No data was found.")
    end

    local end_record = records[#records]
    local end_commit = nil

    if start_record ~= end_record
    then
        end_commit = end_record:get_details().git_commit
    end

    local source_path = start_details.file_path
    local repository = start_details.repository

    M.open_diff_records(
        source_path,
        repository,
        start_commit,
        end_commit,
        replacement_window
    )
end


function M.open_diff_records(
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

    local template = "git show %s:%s"
    local start_command = string.format(template, start_commit, path)
    local start_success, start_stdout, _ = unpack(
        terminal.run(start_command, { cwd=repository })
    )

    if not start_success
    then
        vim.api.nvim_err_writeln(
            string.format(
                'Start-commit command "%s" at directory "%s" failed to run with "%s".',
                start_command,
                repository,
                table.concat(start_stdout, "\n")
            )
        )

        return
    end

    local end_command = string.format(template, end_commit, path)
    local end_success, end_stdout, _ = unpack(
        terminal.run(end_command, { cwd=repository })
    )

    if not end_success
    then
        vim.api.nvim_err_writeln(
            string.format(
                'End-commit command "%s" at directory "%s" failed to run with "%s".',
                end_command,
                repository,
                table.concat(end_stdout, "\n")
            )
        )


        return
    end

    if replacement_window ~= nil
    then
        vim.api.nvim_set_current_win(replacement_window)
        vim.cmd.enew()
    else
        vim.cmd.vnew()
    end

    _make_window(path, repository, start_commit, start_stdout)
    vim.cmd.diffthis()  -- Mark the first window to diff from
    vim.cmd.vnew()
    _make_window(path, repository, end_commit, end_stdout)
    vim.cmd.diffthis()  -- Mark this last window to diff to
end


return M
