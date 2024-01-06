--- Call "git" commands on the terminal
---
--- @module 'timeline._core.git_utilities.git_parser'
---

local filer = require("timeline._core.vim_utilities.filer")
local tabler = require("timeline._core.vim_utilities.tabler")
local terminal = require("timeline._core.vim_utilities.terminal")
local text_mate = require("timeline._core.vim_utilities.text_mate")


local M = {}

--- @class NotePayload
---     Extra information added onto commits that indicates what the commit is about.
--- @field record_type string
---     A description of what type of commit this is. e.g. a "Undo / Redo",
---     "File Save", or something else.
--- @field timeline_version Version
---     When Timeline Viewer creates a git commit, we save the "current
---     version" of Timeline Viewer into the NotePayload in case we need it for
---     backwards compatibility reasons later.


--- Find the source code of `path`, in `repository`, at git `commit`.
---
--- @param path string A relative path to some git-tracked file path.
--- @param repository string The absolute directory on-disk for a git repository.
--- @param commit string Some ID to search within `repository`. e.g. `"a93afa9"`.
--- @return string[]? # The source code that was found, if any.
---
function M.get_commit_text(path, repository, commit)
    local template = "git --no-pager show %s:%s"
    local command = string.format(template, commit, path)
    local success, stdout, _ = unpack(
        terminal.run(command, { cwd=repository })
    )

    if success
    then
        return stdout
    end

    vim.api.nvim_err_writeln(
        string.format(
            'Commit command "%s" at directory "%s" failed to run with "%s".',
            command,
            repository,
            vim.inspect(stdout)
        )
    )

    return nil
end


--- Find all changes for `path` between `start_index` and `end_index`.
---
--- Important:
---     This function is *inclusive*. The returned commits will include at
---     least `start_index` and `end_index` in the output.
---
--- @param path string A relative path to some git-tracked file path.
--- @param repository string The absolute directory on-disk for a git repository.
--- @param start_index number A 0-or-more value indicating the first change to return.
--- @param end_index number A 1-or-more value indicating the last change to return.
--- @return string[]? # The found commits, if any.
---
function M.get_latest_changes(path, repository, start_index, end_index)
    -- Reference: https://www.reddit.com/r/git/comments/18u7e7s/comment/kfjb9fl/?utm_source=share&utm_medium=web2x&context=3
    local command = string.format(
        'git --no-pager log --skip=%s --max-count=%s --pretty=format:"%%h" -- \'%s\'',
        start_index - 1,
        end_index - start_index - 1,
        path
    )

    local success, stdout, stderr = unpack(terminal.run(command, {cwd=repository}))

    if not success
    then
        vim.api.nvim_err_writeln(string.format('Command "%s" failed to run.', command))
        vim.api.nvim_err_writeln(stderr)

        return nil
    end

    stdout = tabler.filter_item("", stdout)

    return stdout
end


--- Get a JSON payload from a git note, if it exists.
---
--- @param repository string The absolute directory on-disk for a git repository.
--- @param commit string Some ID to search within `repository`. e.g. `"a93afa9"`.
--- @return NotePayload? The found note data, if any.
---
function M.get_notes(repository, commit)
    local command = "git notes show " .. commit
    local success, stdout, _ = unpack(terminal.run(command, { cwd=repository }))

    if success
    then
        local data
        success, data = pcall(vim.fn.json_decode, stdout[1])

        if not success
        then
            -- The `git notes` found a note but it wasn't JSON-friendly. Fail early
            return nil
        end

        return data
    end

    stdout = tabler.filter_item("", stdout)

    if text_mate.starts_with(stdout[1], "error: no note found for ")
    then
        -- Git errors if no note is found. It's fine, just ignore it.
        return nil
    end

    vim.api.nvim_err_writeln(
        string.format('Command "%s" at "%s" failed to run.', command, repository)
    )
    vim.api.nvim_err_writeln(vim.inspect(stdout))

    return nil
end


--- Convert `path` into a git-
---
--- @param path string
---     An absolute path to a file on-disk.
--- @return string
---     A relative path that is compatible with the git repository located at
---     `backup_repository_path`.
---
function M.get_backup_repository_path(path)
    local stripped = filer.lstrip_path(path)
    local repository_relative_path = filer.join_path({vim.fn.hostname(), stripped})

    return repository_relative_path
end


--- Find the top-most directory of some git repository.
---
--- @param path string
---     Some absolute path that we expect to be within a git repository.
--- @return string?
---     The found directory, if any. If `path` isn't in a git repository,
---     nothing is returned.
---
function M.get_repository_root(path)
    local command = "git rev-parse --show-toplevel"
    local success, stdout, stderr = unpack(terminal.run(command, { cwd=path }))

    if not success
    then
        vim.api.nvim_err_writeln(string.format('Command "%s" failed to run.', command))
        vim.api.nvim_err_writeln(stderr)

        return nil
    end

    stdout = tabler.filter_item("", stdout)

    return stdout[1]
end


-- function M.parse_git_diff_short_stat(text)
--     -- TODO: Add unittests for these example strings
--     -- 5 files changed, 241 insertions(+), 30 deletions(-)
--     -- 1 file changed, 66 insertions(+), 1 deletion(-)
--     -- 1 file changed, 66 insertions(+)
--     -- 1 file changed, 12 deletions(-)
--
--     local deletions
--     local deletions_remainder
--     local files
--     local insertions
--     local insertions_remainder
--     local remainder
--
--     local prefix = "(%d+)%sfile[s]?%schanged(.+)"
--     files, remainder = text:match(prefix)
--     local output = {files=files}
--
--     if remainder == nil
--     then
--         return output
--     end
--
--     local insertions_pattern = ",%s(%d+)%sinsertion[s]?%([+]%)(.*)"
--     insertions, insertions_remainder = remainder:match(insertions_pattern)
--
--     local deletions_pattern = ",%s(%d+)%sdeletion[s]?%([-]%)(.*)"
--
--     if insertions ~= nil
--     then
--         if insertions_remainder ~= nil
--         then
--             deletions, _ = insertions_remainder:match(deletions_pattern)
--         end
--     else
--         deletions, deletions_remainder = remainder:match(deletions_pattern)
--
--         if deletions_remainder ~= nil
--         then
--             insertions, remainder = deletions_remainder:match(insertions_pattern)
--         end
--     end
--
--     output.insertions = tonumber(insertions)
--     output.deletions = tonumber(deletions)
--
--     return output
-- end


return M
