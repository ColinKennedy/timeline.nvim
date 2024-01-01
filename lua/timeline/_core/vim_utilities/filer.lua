local Path = require("plenary.path")

--- Functions for working with disk-like file/folder paths.
---
--- @module 'timeline._core.vim_utilities.filer'
---

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


--- Join `parts` into a file / folder path.
---
--- @param parts string[] The folder / file names to join. e.g. `{"/foo", "bar"}`.
--- @return string # The joined path. e.g. `"/foo/bar"`.
---
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


--- Create a relative path starting from `root`, pointing to `full_path`.
---
--- @param root string The absolute directory to make-relative.
--- @param full_path string An absolute path to return as relative.
--- @return string # The computed relative path.
---
function M.get_relative_path(root, full_path)
    return Path:new(full_path):make_relative(root)
end


--- Make `path` into a "relative" path by removing any leading qualifiers.
---
--- @param path string Some absolute path like `"/home/foo"`.
--- @return string # The same `path` but without the leading "/".
---
function M.lstrip_path(path)
    return path:gsub("^[/\\]+", "")
end


return M
