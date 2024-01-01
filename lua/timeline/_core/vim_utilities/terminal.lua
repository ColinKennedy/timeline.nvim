--- Functions for working running CLI / terminal commands.
---
--- @module 'timeline._core.vim_utilities.terminal'
---

local tabler = require("timeline._core.vim_utilities.tabler")

local M = {}


--- @class _ShellArguments
--- @field cwd string? The directory on-disk where a shell command will be called from.
--- @field on_stderr fun(job_id: integer, data: table<string>, event): nil An on-error callback.

--- Run `command` with shell `options` and indicate if the call succeeded.
---
--- @param command string The shell command to call. No string escapes needed.
--- @param options _ShellArguments Optional data to include for the shell command.
--- @return boolean If success, return `true`.
---
local _run_shell_command = function(command, options)
    local options = options or {}
    local job = vim.fn.jobstart(command, options)
    local result = vim.fn.jobwait({job})[1]

    if result == 0
    then
        return true
    end

    if result == -1
    then
        vim.api.nvim_err_writeln('The requested command "' .. command .. '" timed out.')

        return false
    elseif result == -2
    then
        vim.api.nvim_err_writeln(
            'The requested command "'
            .. vim.inspect(command)
            .. '" was interrupted.'
        )

        return false
    elseif result == -3
    then
        vim.api.nvim_err_writeln('Job ID is invalid "' .. tostring(job) .. '"')

        return false
    else
        -- It's assumed that the caller will want to handle / print this error case
        return false
    end
end


--- Run `command` in a separate shell and return its results.
---
--- @param command string
---     Some CLI/terminal command. e.g. `"ls"`.
--- @param options table<string, object>
---     Options to include for the command. e.g. `{cwd="/path/to/somewhere"}`.kj
--- @return table<boolean, string[], string[]>
---     The boolean means "did this command exit with a 0 return code".
---     The arrays of strings are stdout and stderr.
---
function M.run(command, options)
    options = options or {}
    local stderr = {}
    local stdout = {}

    options = vim.tbl_deep_extend(
        "keep",
        {
            on_stderr=function(_, data, _) tabler.extend(data, stdout) end,
            on_stdout=function(_, data, _)
                tabler.extend(data, stdout)
            end,
        },
        options
    )

    local success = _run_shell_command(command, options)

    return {success, stdout, stderr}
end


return M
