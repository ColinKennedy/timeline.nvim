local luatz = require("timeline._vendors.luatz")

local base = require("timeline._core.sources.base")
local configuration = require("timeline._core.configuration")
local constant = require("timeline._core.constant")
local differ = require("timeline._core.actions.differ")
local git_parser = require("timeline._core.git_utilities.git_parser")
local record_ = require("timeline._core.components.record")
local tabler = require("timeline._core.vim_utilities.tabler")


local M = {}

M.Source = base.Source:new()


local function _collect(payload, icon)
    local output = {}

    -- TODO: Add this back in later
    -- for _, repository in ipairs(configuration.repository_paths)
    for _, repository in ipairs({"/home/selecaoone/.vim_custom_backups"})
    do
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
            local get_datetime_number = function()
                return git_parser.get_commit_datetime(commit, repository)
            end

            table.insert(
                output,
                -- TODO: Figure out how to defer all of this but still do as few
                -- git queries as possible
                --
                record_.Record:new(
                    {
                        actions=function()
                            return { open = differ.open_diff_records_and_summary }
                        end,
                        datetime_number=get_datetime_number,
                        datetime_text=function()
                            local datetime = get_datetime_number()

                            if datetime == nil
                            then
                                return "<No datetime found>"
                            end

                            return luatz.timetable.new_from_timestamp(tonumber(datetime))
                        end,
                        -- TODO: Add this, later
                        details=function()
                            return {
                                file_path = repository_path,
                                git_commit = commit,
                                repository = repository,
                            }
                        end,
                        icon=function()
                            return icon
                        end,
                        label=function()
                            return "File Save"
                        end,
                        -- source=self, -- TODO: Not sure if I'll need this
                        record_type=function()
                            return constant.RecordTypes.file_save
                        end,
                        source_type=function()
                            return constant.SourceTypes.git_commit
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

    tabler.extend(_collect(payload, self:get_icon()), results)

    return results
end


function M.Source:new()
    local instance = base.Source:new(instance)
    setmetatable(instance, self)
    self.__index = self

    return instance
end


return M
