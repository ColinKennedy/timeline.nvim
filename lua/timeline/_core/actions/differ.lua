local terminal = require("timeline._core.vim_utilities.terminal")

local M = {}

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

    print(start_success)
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

    print("GOING INTO DIFF MODE")
    print(vim.inspect(start_stdout))
    print(vim.inspect(end_stdout))
end


return M
