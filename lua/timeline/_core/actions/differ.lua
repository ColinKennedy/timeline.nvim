local terminal = require("timeline._core.vim_utilities.terminal")

local M = {}


local function _make_window(path, repository, commit, text)
    -- This file name is a simple URI, since it's a snapshot in time and not a real file
    vim.cmd(string.format("file git_commit:%s:%s:%s", path, repository, commit))
    local buffer = 0
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, text)
    -- vim.api.nvim_buf_set_option(buffer, "modifiable", false)
end


function M.diff_records(path, repository, start_commit, end_commit)
    if end_commit == nil
    then
        end_commit = start_commit .. "~"
    end

    local template = "git show %s:%s"
    local start_command = string.format(template, start_commit, path)
    local start_success, start_stdout, start_stderr = unpack(
        terminal.run(
            start_command,
            {cwd=repository}
        )
    )

    if not start_success
    then
        vim.api.nvim_err_writeln(
            string.format(
                'Start-commit command "%s" failed to run with "%s".',
                start_command,
                table.concat(start_stderr, "\n")
            )
        )

        return
    end

    local end_success, end_stdout, end_stderr = unpack(
        terminal.run(
            string.format(template, end_commit, path),
            {cwd=repository}
        )
    )

    if not end_success
    then
        vim.api.nvim_err_writeln(
            string.format(
                'End-commit command "%s" failed to run with "%s".',
                end_command,
                table.concat(end_stderr, "\n")
            )
        )


        return
    end

    vim.cmd.vnew()
    _make_window(path, repository, start_commit, start_stdout)
    vim.cmd.diffthis()  -- Mark the first window to diff from
    vim.cmd.vnew()
    _make_window(path, repository, end_commit, end_stdout)
    vim.cmd.diffthis()  -- Mark this last window to diff to
end


return M
