local tabler = require("timeline._core.utilities.tabler")

local M = {}


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
    end

    -- TODO: Possible remove this
    return true
end


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
