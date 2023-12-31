local base = require("timeline._core.sources.base")
local configuration = require("timeline._core.configuration")
local constant = require("timeline._core.constant")
local differ = require("timeline._core.actions.differ")
local filer = require("timeline._core.vim_utilities.filer")
local record_ = require("timeline._core.components.record")
local tabler = require("timeline._core.vim_utilities.tabler")
local terminal = require("timeline._core.vim_utilities.terminal")

local M = {}

M.Source = base.Source:new()


local function _get_commit_datetime(commit, repository)
    local command = string.format("git show --no-patch --format=%%ci %s", commit)
    local success, stdout, stderr = unpack(terminal.run(command, {cwd=repository}))

    if not success
    then
        vim.api.nvim_err_writeln(string.format('Command "%s" failed to run.', command))
        vim.api.nvim_err_writeln(stderr)

        return nil
    end

    stdout = tabler.filter("", stdout)

    return stdout[1]
end


local function _get_latest_commits(repository, path, start_index, end_index)
    local command = string.format(
        'git log -%s --pretty=format:"%%h" -- \'%s\'',
        end_index,
        path
    )

    local success, stdout, stderr = unpack(terminal.run(command, {cwd=repository}))

    if not success
    then
        vim.api.nvim_err_writeln(string.format('Command "%s" failed to run.', command))
        vim.api.nvim_err_writeln(stderr)

        return nil
    end

    stdout = tabler.filter("", stdout)

    return tabler.slice(stdout, start_index)
end


local function _get_latest_commits(repository, path, start_index, end_index)
    -- Reference: https://www.reddit.com/r/git/comments/18u7e7s/comment/kfjb9fl/?utm_source=share&utm_medium=web2x&context=3
    local command = string.format(
        'git log --skip=%s --max-count=%s --pretty=format:"%%h" -- \'%s\'',
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

    stdout = tabler.filter("", stdout)

    return stdout
end


local function _get_repository_path(path)
    local stripped = filer.lstrip_path(path)
    local repository_relative_path = filer.join_path({vim.fn.hostname(), stripped})

    return repository_relative_path
end


local function _open_as_diff_and_summary(records)
    -- TODO: Add the summary
    local start_record = records[1]

    local start_details = start_record:get_details()
    local start_commit = start_details.git_commit

    if start_commit == nil
    then
        vim.api.nvim_err_writeln("Cannot load diff. No data was found.")
    end

    local end_record = records[#records]
    local end_commit = nil

    if start_record ~= end_record
    then
        end_commit = end_record:get_details().git_commit
    end

    local source_path = start_details.file_path
    local repository = start_details.repository

    differ.diff_records(source_path, repository, start_commit, end_commit)
end


local function _collect(payload, icon)
    local output = {}

    -- TODO: Add this back in later
    -- for _, repository in ipairs(configuration.repository_paths)
    for _, repository in ipairs({"/home/selecaotwo/.vim_custom_backups"})
    do
        local repository_path = _get_repository_path(payload.path)

        for _, commit in ipairs(
            _get_latest_commits(
                repository,
                repository_path,
                payload.offset,
                payload.height + payload.offset
            ) or {}
        )
        do
            table.insert(
                output,
                -- TODO: Figure out how to defer all of this but still do as few
                -- git queries as possible
                --
                record_.Record:new(
                    {
                        actions=function()
                            return { open = _open_as_diff_and_summary }
                        end,
                        datetime=function()
                            return _get_commit_datetime(commit, repository)
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
    return "file"
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
    -- instance.get_icon = M.Source.get_icon
    -- instance.get_name = M.Source.get_name
    -- instance.collect = M.Source.collect

    return instance
end


return M
