--- The main module for reading "local" git repository data for files.
---
--- This is pretty much just local git commit records, maybe some other rarer
--- record types, and nothing else.
---
--- @module 'timeline._core.sources.git'
---

local base = require("timeline._core.sources.base")
local cache = require("timeline._core.components.cache")
local configuration = require("timeline._core.configuration")
local constant = require("timeline._core.constant")
local differ = require("timeline._core.actions.differ")
local filer = require("timeline._core.vim_utilities.filer")
local git_cache = require("timeline._core.sources.middleware.git_cache")
local git_parser = require("timeline._core.git_utilities.git_parser")
local record_ = require("timeline._core.components.record")
local tabler = require("timeline._core.vim_utilities.tabler")


local M = {}

M.Source = base.Source:new()


--- Parse `payload` for timeline.nvim records.
---
--- @param payload Request
---     A description of how many records to collect, starting from which index, etc.
--- @param icon string
---     A character which will display along with each found Record.
--- @return Record[]
---     The found records, if any.
---
local function _collect(payload, icon)
    local output = {}

    local absolute_repository_path = payload.path
    local repository = git_parser.get_repository_root(
        vim.fn.fnamemodify(absolute_repository_path, ":h")
    )

    if repository == nil
    then
        -- Exit silently because this source will be effectively disabled
        return {}
    end

    local repository_path = filer.get_relative_path(repository, payload.path)

    cache.initialize_repository(repository)

    local commits = git_parser.get_latest_changes(
        repository_path,
        repository,
        payload.offset,
        payload.height + payload.offset
    ) or {}

    git_cache.update_cache_for_commits(repository, commits)

    for _, commit in ipairs(commits)
    do
        local get_datetime = function()
            return cache.get_cached_commit(repository, commit):get_author_date()
        end

        table.insert(
            output,
            -- TODO: Figure out how to defer all of this but still do as few
            -- git queries as possible
            --
            record_.Record:new(
                {
                    actions=function()
                        return {
                            open = function(records)
                                local window = payload.source_window

                                if not vim.api.nvim_win_is_valid(window)
                                then
                                    window = nil
                                end

                                differ.open_diff_records_and_summary(records, window)
                            end,
                            show_diff = function(records)
                                local window = payload.source_window

                                if not vim.api.nvim_win_is_valid(window)
                                then
                                    window = nil
                                end

                                differ.open_diff_records(records, window)
                            end,
                            view_this = function(record)
                                local window = payload.source_window

                                if not vim.api.nvim_win_is_valid(window)
                                then
                                    window = nil
                                end

                                local text = git_parser.get_commit_text(
                                    repository_path,
                                    repository,
                                    commit
                                )

                                vim.api.nvim_set_current_win(window)
                                vim.cmd.enew()

                                git_buffer.make_read_only_view(
                                    repository_path,
                                    repository,
                                    commit,
                                    text
                                )
                            end,
                        }
                    end,
                    datetime = get_datetime,
                    -- TODO: Add this, later
                    details=function()
                        return {
                            git_commit = commit,
                            git_commit_details = cache.get_cached_commit(repository, commit),
                            repository_path = repository_path,
                            repository_root = repository,
                        }
                    end,
                    icon=function()
                        return icon
                    end,
                    label=function()
                        return "Git Commit"
                    end,
                    -- source=self, -- TODO: Not sure if I'll need this
                    record_type=function()
                        return constant.RecordTypes.git_commit
                    end,
                    source_type=function()
                        return constant.SourceTypes.git
                    end
                }
            )
        )
    end

    return output
end


--- @return string A description of where some record was found.
function M.Source:get_type()
    return constant.SourceTypes.git
end


--- Parse `payload` for timeline.nvim records.
---
--- @param payload Request
---     A description of how many records to collect, starting from which index, etc.
--- @return Record[]
---     The found records, if any.
---
function M.Source:collect(payload)
    local results = base.Source.collect(self, payload)

    tabler.extend(results, _collect(payload, configuration.DATA.records.git_commit.icon))

    return results
end


--- @return Source # Create a new instance.
function M.Source:new()
    local instance = base.Source:new(instance)
    setmetatable(instance, self)
    self.__index = self

    return instance
end


return M
