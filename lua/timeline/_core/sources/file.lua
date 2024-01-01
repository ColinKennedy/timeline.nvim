local base = require("timeline._core.sources.base")
local configuration = require("timeline._core.configuration")
local constant = require("timeline._core.constant")
local date_mate = require("timeline._core.git_utilities.date_mate")
local differ = require("timeline._core.actions.differ")
local git_parser = require("timeline._core.git_utilities.git_parser")
local record_ = require("timeline._core.components.record")
local tabler = require("timeline._core.vim_utilities.tabler")


local M = {}

M.Source = base.Source:new()


local function _get_label_from_type(record_type)
    local labels = {
        file_save = "File Save",
        undo_redo = "Undo / Redo",
    }

    return labels[record_type]
end


local function _collect(payload)
    local output = {}

    -- TODO: Find a better way to implement a cache
    local cache = {}

    for _, repository in ipairs(configuration.DATA.source_repository_paths)
    do
        cache[repository] = {}

        local repository_path = git_parser.get_repository_path(payload.path)

        for _, commit in ipairs(
            git_parser.get_latest_changes(
                repository,
                repository_path,
                payload.offset,
                payload.height + payload.offset
            ) or {}
        )
        do
            cache[repository][commit] = {}

            local get_datetime = function()
                if cache[repository][commit]["datetime"] ~= nil
                then
                    return cache[repository][commit]["datetime"]
                end

                local unix_epoch = git_parser.get_commit_datetime(commit, repository)

                if unix_epoch == nil
                then
                    return nil
                end

                local datetime = date_mate.get_datetime_with_timezone(unix_epoch)

                cache[repository][commit]["datetime"] = datetime

                return cache[repository][commit]["datetime"]
            end

            local notes = git_parser.get_notes(repository, commit)
            local source_type = constant.SourceTypes.git_commit

            local record_type = nil

            if notes ~= nil
            then
                record_type = notes.record_type
            else
                -- Just assume that the commit is a normal file save, in this case
                record_type = constant.RecordTypes.file_save
            end

            local label = _get_label_from_type(record_type)
            local icon = configuration.DATA.records[record_type].icon

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
                                restore = function(record)
                                    local template = "git show %s:%s"
                                    local command = string.format(template, commit, repository_path)
                                    local success, stdout, _ = unpack(
                                        terminal.run(command, { cwd=repository })
                                    )

                                    if not success
                                    then
                                        vim.api.nvim_err_writeln(
                                            string.format(
                                                'Cannot restore. Command "%s" at directory "%s" failed to run with "%s".',
                                                command,
                                                repository,
                                                table.concat(stdout, "\n")
                                            )
                                        )

                                        return
                                    end
                                end,
                                show_diff = function(records)
                                    local window = payload.source_window

                                    if not vim.api.nvim_win_is_valid(window)
                                    then
                                        window = nil
                                    end

                                    differ.open_diff_records(records, window)
                                end,
                            }
                        end,
                        datetime_number=function()
                            return get_datetime():timestamp()
                        end,
                        datetime_text=function()
                            -- TODO: Add caching
                            local datetime = get_datetime()

                            if datetime == nil
                            then
                                return "<No datetime found>"
                            end

                            return datetime:strftime(
                                configuration.DATA.timeline_window.datetime.format
                            )
                        end,
                        -- TODO: Add this, later
                        details=function()
                            return {
                                git_commit = commit,
                                repository_path = repository_path,
                                repository_root = repository,
                            }
                        end,
                        icon=function()
                            return icon
                        end,
                        label=function()
                            return label
                        end,
                        -- source=self, -- TODO: Not sure if I'll need this
                        record_type=function()
                            return record_type
                        end,
                        source_type=function()
                            return source_type
                        end
                    }
                )
            )
        end
    end

    return output
end


function M.Source:get_type()
    return constant.SourceTypes.file
end


function M.Source:collect(payload)
    local results = base.Source.collect(self, payload)

    tabler.extend(_collect(payload), results)

    return results
end


function M.Source:new()
    local instance = base.Source:new(instance)
    setmetatable(instance, self)
    self.__index = self

    return instance
end


return M
