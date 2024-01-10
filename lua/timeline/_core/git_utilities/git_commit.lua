--- A module for gathering important details about git commits.
---
--- @module 'timeline._core.git_utilities.git_commit'
---

local constant = require("timeline._core.constant")
local date_mate = require("timeline._core.git_utilities.date_mate")
local tabler = require("timeline._core.vim_utilities.tabler")


local M = {}

--- @class GitCommitDetails
---     Parsed information about some git commit that can be conveniently queried.
--- @method get_author_date fun(self: GitCommitDetails): luatz.timetable
---     Get date for the first time that this commit was created.
--- @method get_notes fun(self: GitCommitDetails): table<str, ...>
---     When timeline.nvim creates git commits in the `backup_repository_path`,
---     it attaches extra information about the commit that is needed by
---     timeline.nvim. This method pulls that data out.
--- @method new_from_data fun(table<string, ...>): GitCommitDetails
---     An initialization method that takes in the parsed results of `git show ...`
---     and gives back a new, valid instance.

M.Details = {}


--- Find the first line-index in `lines` that matches `key`.
---
--- @param lines string[] Some text to check.
--- @param key string An exact match to expect.
--- @return boolean # If there's a match, return `true`.
---
local function _get_first_index(lines, key)
    for index, line in ipairs(lines)
    do
        if line == key
        then
            return index
        end
    end

    return nil
end


--- Find the line-index that matches the start of a git message.
---
--- @param lines string[] Some text to check.
--- @return boolean # If there's a match, return `true`.
---
local function _get_message_start_index(lines)
    return _get_first_index(lines, constant.GIT_MESSAGE_START)
end


--- Find the line-index that matches the end of a git note.
---
--- @param lines string[] Some text to check.
--- @return boolean # If there's a match, return `true`.
---
local function _get_note_end_index(lines)
    return _get_first_index(lines, constant.GIT_NOTE_END)
end


--- Find the line-index that matches the start of a git note.
---
--- @param lines string[] Some text to check.
--- @return boolean # If there's a match, return `true`.
---
local function _get_note_start_index(lines)
    return _get_first_index(lines, constant.GIT_NOTE_START)
end


-- TODO: Make this into a proper Lua table / interface
--- Read the contents of a previously-authored-by-timeline.nvim git note.
---
--- @param text string
---     A raw blob of text to parse, usually from a `git notes show` command.
--- @return table<string, ...>?
---     The found data, if any.
---
local function _parse_git_note(text)
    local success, data = pcall(vim.fn.json_decode, text)

    if not success
    then
        return nil
    end

    -- TODO: Make this into a proper Lua class, instead
    return data
end


--- Make a new instance of GitCommitDetails using `data`.
---
--- @param data table<string, ...>
---     The converted data from `convert_from_raw_git_show`.
--- @return GitCommitDetails
---     The created, new instance.
---
function M.Details:new_from_data(data)
    local self = setmetatable({}, { __index = M.Details })

    self._author = data.author
    self._commit = data.commit
    self._email = data.email
    self._message = data.message
    self._notes = data.notes
    self._parents = data.parents

    self._author_date = data.author_date
    self._commit_date = data.commit_date

    self._short_stat = data.short_stat

    return self
end


--- @return luatz.timetable # The first date-time which this commit was authored.
function M.Details:get_author_date()
    return self._author_date
end


--- @return string The full name of the git commit creator.
function M.Details:get_author()
    return self._author
end


--- @return string The git commit hash for this instance.
function M.Details:get_commit()
    return self._commit
end


--- @return string An address which can be used to contact the git commit creator.
function M.Details:get_email()
    return self._email
end


--- @return string The user-provided details about what this commit represents.
function M.Details:get_message()
    return self._message
end


--- @return table<string, ...>? # Any timeline.nvim-related metadata for the commit.
function M.Details:get_notes()
    return self._notes
end


-- TODO: Make sure that this parsing works even if 1. The git message is multi-line 2. The git note is multi-line
--- Parse all of the `git show` details into a table of data.
---
--- The expected format for this function is `git show --no-patch
--- --format=%H%n%aN%n%aE%n%at%n%ct%n%P%n%D%n%N%n%B -z`.
---
--- @param text string[]
---     A blob of data from `git show` whose lines will checked and parsed.
--- @return table<string, ...>
---     The converted data.
---
function M.convert_from_raw_git_show(text)
    local parents = {}

    for parent in string.gmatch(text[6], "([^ ]+)")
    do
        table.insert(parents, parent)
    end

    local ref_names = {}

    for name in string.gmatch(text[7], "([^,]+)")
    do
        table.insert(ref_names, name)
    end

    local author_date
    local author_date_epoch = tonumber(text[4])

    if author_date_epoch ~= nil
    then
        author_date = date_mate.get_datetime_with_timezone(author_date_epoch)
    end

    local commit_date
    local commit_date_epoch = tonumber(text[5])

    if commit_date_epoch ~= nil
    then
        commit_date = date_mate.get_datetime_with_timezone(commit_date_epoch)
    end

    local note_start = _get_note_start_index(text)
    local notes = nil

    if note_start ~= nil
    then
        local note_end = _get_note_end_index(text)
        notes = _parse_git_note(
            table.concat(tabler.slice(text, note_start + 1, note_end + 1), "\n")
        )
    end

    local message_start = _get_message_start_index(text)
    local message = nil

    if message_start ~= nil
    then
        message = table.concat(tabler.slice(text, message_start + 1), "\n")
    end

    return {
        -- short_stat = git_parser.parse_git_diff_short_stat(text[9]), -- TODO: Check if I still need this
        author = text[2],
        author_date = author_date,
        commit = text[1],
        commit_date = commit_date,
        email = text[3],
        message = message,
        notes = notes,
        parents = parents,
        ref_names = ref_names,
    }
end


return M
