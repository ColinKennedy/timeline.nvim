--- Keep track of pre-computed data so that the tool runs faster.
---
--- @module 'timeline._core.components.cache'
---

-- TODO: Figure out how to cache things more simply

local M = {}

local _GIT_COMMIT_CACHE = {}


-- TODO: Do I actually need these initializations?
--- Add missing tables for `repository` and `commit` so it can be cached, later.
---
--- @param repository string
---     An absolute path to some git repository. e.g. `"~/.vim_custom_backups"`.
--- @param commit string
---     Some git commit hash to check from. e.g. `"a93afa9"`.
---
function M.initialize_commit(repository, commit)
    if _GIT_COMMIT_CACHE[repository][commit] == nil
    then
        _GIT_COMMIT_CACHE[repository][commit] = {}
    end
end


--- Add missing tables for `repository` so its commits can be cached, later.
---
--- @param repository string
---     An absolute path to some git repository. e.g. `"~/.vim_custom_backups"`.
---
function M.initialize_repository(repository)
    if _GIT_COMMIT_CACHE[repository] == nil
    then
        _GIT_COMMIT_CACHE[repository] = {}
    end
end


--- Check if `repository` and `commit` already have cached data.
---
--- @param repository string
---     An absolute path to some git repository. e.g. `"~/.vim_custom_backups"`.
--- @param commit string
---     Some git commit hash to check from. e.g. `"a93afa9"`.
--- @return boolean
---     If the `commit` is cached, return `true`.
---
function M.has_cached_commit(repository, commit)
    return not vim.tbl_isempty(_GIT_COMMIT_CACHE[repository][commit])
end


--- Get the git data from `commit` in `repository`.
---
--- @param repository string
---     An absolute path to some git repository. e.g. `"~/.vim_custom_backups"`.
--- @param commit string
---     Some git commit hash to check from. e.g. `"a93afa9"`.
--- @return GitCommitDetails?
---     The cached data, if any.
---
function M.get_cached_commit(repository, commit)
    return _GIT_COMMIT_CACHE[repository][commit]
end


--- Cache `details` onto `commit` in `repository`.
---
--- @param repository string
---     An absolute path to some git repository. e.g. `"~/.vim_custom_backups"`.
--- @param commit string
---     Some git commit hash to check from. e.g. `"a93afa9"`.
--- @param details GitCommitDetails
---     The pre-computed commit information to keep track of.
---
function M.set_cached_commit(repository, commit, details)
    _GIT_COMMIT_CACHE[repository][commit] = details
end


return M
