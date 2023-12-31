local M = {}

M.os_separator = package.config:sub(1, 1)

if vim.fn.has("win32") == 1
then
    M.command_separator = ";"
    M.path_separator = ";"
elseif vim.fn.has("unix") == 1
then
    M.command_separator = ";"
    M.path_separator = ":"
else
    vim.api.nvim_err_writeln("Not sure what OS path separator to use")

    M.command_separator = ";"
    M.path_separator = ":"
end


function M.join_path(parts)
    local output = ""

    for _, part in ipairs(parts)
    do
        if output == ""
        then
            output = part
        else
            output = output .. M.os_separator .. part
        end
    end

    return output
end


function M.join_os_paths(paths)
    local output = ""

    for _, path in ipairs(paths)
    do
        if output == ""
        then
            output = path
        else
            output = output .. M.path_separator .. path
        end
    end

    return output
end


function M.lstrip_path(path)
    return path:gsub("^[/\\]+", "")
end

return M
