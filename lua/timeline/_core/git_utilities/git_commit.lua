--- A module for gathering important details about git commits.
---
--- @module 'timeline._core.git_utilities.git_commit'
---

local date_mate = require("timeline._core.git_utilities.date_mate")
local terminal = require("timeline._core.vim_utilities.terminal")


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
local function _convert_from_raw_git_show(text)
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

    local notes = _parse_git_note(text[8])

    return {
        -- short_stat = git_parser.parse_git_diff_short_stat(text[9]), -- TODO: Check if I still need this
        author = text[2],
        author_date = author_date,
        commit = text[1],
        commit_date = commit_date,
        email = text[3],
        message = text[10],
        notes = notes,
        parents = parents,
        ref_names = ref_names,
    }
end


--- Make a new instance of GitCommitDetails using `data`.
---
--- @param data table<string, ...>
---     The converted data from `_convert_from_raw_git_show`.
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


--- @return table<string, ...>? # Any timeline.nvim-related metadata for the commit.
function M.Details:get_notes()
    return self._notes
end


--- Query and parse all of the details of `commit` in `repository`.
---
--- @param commit string
---     Some git commit hash to check from. e.g. `"a93afa9"`.
--- @param repository string
---     An absolute path to some git repository. e.g. `"~/.vim_custom_backups"`.
--- @return GitCommitDetails?
---     The created, new instance.
---
function M.get_commit_details(commit, repository)
    local command = "git show --no-patch --format=%H%n%aN%n%aE%n%at%n%ct%n%P%n%D%n%N%n%B -z " .. commit
    local success, stdout, _ = unpack(terminal.run(command, {cwd=repository}))

    if not success
    then
        vim.api.nvim_err_writeln(
            string.format(
                'Git show command "%s" at directory "%s" failed to run with "%s".',
                vim.inspect(stdout)
            )
        )

        return nil
    end

    local data = _convert_from_raw_git_show(stdout)

    return M.Details:new_from_data(data)
end


return M
