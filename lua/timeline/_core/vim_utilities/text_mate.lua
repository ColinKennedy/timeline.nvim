--- A module for making text-manipulation in Lua a bit easier.
---
--- @module 'timeline._core.vim_utilities.text_mate'
---

local M = {}


--- Check if `text` is all whitespace or an empty string.
---
--- @param text string Some text to check. e.g. `"  "`.
--- @return boolean # If `text` is empty, return `true`.
---
function M.is_empty(text)
    return text:match("^%s*$") ~= nil
end


--- Check if `full` starts with `prefix` text.
---
--- @param full string Some text to compare from. e.g. `"foobar"`.
--- @param prefix string some text to compare with. e.g. `"foob"`.
--- @return boolean # If `full` starts with `prefix`, return `true`.
---
function M.starts_with(full, prefix)
    return full:sub(1, #prefix) == prefix
end


return M
