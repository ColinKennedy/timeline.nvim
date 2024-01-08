--- A separate module to mix "timeline.nvim cache" and "git commit" stuff together.
---
--- @module 'timeline._core.sources.middleware.git_cache'
---

local cache = require("timeline._core.components.cache")
local constant = require("timeline._core.constant")
local git_commit = require("timeline._core.git_utilities.git_commit")
local tabler = require("timeline._core.vim_utilities.tabler")
local terminal = require("timeline._core.vim_utilities.terminal")
local text_mate = require("timeline._core.vim_utilities.text_mate")

local M = {}


--- Split `all_lines` by each git commit.
---
--- @param all_lines string[] Raw `git show` text.
--- @return table<string, GitCommitDetails> # The parsed git data, if any.
---
local function _parse_all_commit_lines(all_lines)
    local lines = {}
    local current_commit = nil
    local output = {}

    for _, line in ipairs(all_lines)
    do
        if current_commit == nil and not text_mate.is_empty(line)
        then
            -- We assume that the first non-empty line is the commit hash
            current_commit = line
        end

        if line == constant.GIT_DETAILS_LINE_ENDER
        then
            -- We've reached the end of an entry.
            local triaged = git_commit.convert_from_raw_git_show(tabler.copy(lines))
            local details = git_commit.Details:new_from_data(triaged)

            output[current_commit] = details

            -- Reset the `lines` so (if needed) we are ready another round of parsing
            lines = {}
            current_commit = nil
        else
            table.insert(lines, line)
        end
    end

    return output
end


--- Read the contents of `commits` in `repository`.
---
--- @param commits string[]
---     Some git commit hashes to read in the repository. e.g. `{"a93afa9", ...}`.
--- @param repository string
---     An absolute path to some git repository. e.g. `"~/.vim_custom_backups"`.
--- @return table<string, GitCommitDetails>? The parsed commits or nothing, if there's an error.
---
local function _parse_all_commits(commits, repository)
    local command = constant.GIT_DETAILS_FORMAT .. " " .. table.concat(commits, " ")
    local success, stdout, _ = unpack(terminal.run(command, { cwd=repository }))

    if not success
    then
        vim.api.nvim_err_writeln(
            string.format(
                'Command "%s" from "%s" repository could not be run. Error: "%s".',
                command,
                repository,
                vim.inspect(stdout)
            )
        )

        return nil
    end

    return _parse_all_commit_lines(stdout)
end


--- Initialize / Compute caches for `all_commits` in `repository`.
---
--- The Timeline Viewer will need all or parts of the git commit data at any
--- given time. - We query everything, all at once, because it's relatively fast
--- as long as it's done in batch like we do here. And then we don't have to
--- worry about the data being missing or unavailable whenever we need it next.
---
--- @param repository string
---     An absolute path to some git repository. e.g. `"~/.vim_custom_backups"`.
--- @param all_commits string[]
---     Some git commit hashes to read in the repository. e.g. `{"a93afa9", ...}`.
---
function M.update_cache_for_commits(repository, all_commits)
    local commits_to_parse = {}

    for _, commit in ipairs(all_commits)
    do
        cache.initialize_commit(repository, commit)

        if not cache.has_cached_commit(repository, commit)
        then
            table.insert(commits_to_parse, commit)
        end
    end

    if vim.tbl_isempty(commits_to_parse)
    then
        -- If everything is already cached, just do nothing
        return
    end

    local commits = _parse_all_commits(commits_to_parse, repository)

    if commits == nil
    then
        vim.api.nvim_err_writeln(
            string.format(
                'Could not parse "%s" commits from "%s" repository.',
                vim.inspect(commits_to_parse),
                repository
            )
        )

        return
    end

    for commit, details in pairs(commits)
    do
        cache.set_cached_commit(repository, commit, details)
    end
end


return M
