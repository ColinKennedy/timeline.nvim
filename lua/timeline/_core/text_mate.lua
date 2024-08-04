--- Make text manipulation in Lua a bit easier.
---
--- @module 'timeline._core.text_mate'
---

local M = {}

--- Make `full` relative to some `prefix` absolute directory / path.
---
--- @param prefix string The directory like "/foo/bar/".
--- @param full string A full path like "/foo/bar/fizz/buzz.txt".
--- @return string # The relative path like "fizz/buzz.txt".
---
function M.get_relative_path(prefix, full)
    return string.gsub(
        vim.fs.normalize(full),
        vim.fs.normalize(prefix),
        ""
    )
end

--- If `text` includes "/foo", remove the "/".
---
--- @param text string Some directory-like structure to strip.
--- @return string # The stripped text.
---
function M.remove_prefix_directory(text)
    return text:gsub("^[/\\]+", "")
end

return M
