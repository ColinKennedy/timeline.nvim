local base = require("timeline._core.sources.base")
local constant = require("timeline._core.constant")
local filer = require("timeline._core.utilities.filer")
local record_ = require("timeline._core.components.record")
local tabler = require("timeline._core.utilities.tabler")
local terminal = require("timeline._core.utilities.terminal")

local M = {}

M.Source = setmetatable({}, { __index = base.Source })


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


local function _collect(payload)
    local output = {}

    -- TODO: Add this back in later
    -- for _, repository in ipairs(configuration.repository_paths)
    for _, repository in ipairs({"/home/selecaoone/.vim_custom_backups"})
    do
        for _, commit in ipairs(
            _get_latest_commits(
                repository,
                _get_repository_path(payload.path),
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
                            return {
                                Action:new()
                            }
                        end,
                        datetime=function()
                            return _get_commit_datetime(commit, repository)
                        end,
                        -- TODO: Add this, later
                        details=function()
                            return "Details, here"
                        end,
                        icon=function()
                            return ""
                        end,
                        label=function()
                            return "File Save"
                        end,
                        -- source=self, -- TODO: Not sure if I'll need this
                        record_type=constant.RecordTypes.file_save,
                        source_type=constant.SourceTypes.git_commit,
                    }
                )
            )
        end
    end

    return output
end


function M.Source:get_name(self)
    return "File"
end


function M.Source:get_name(self)
    return "File"
end


function M.Source.collect(self, payload)
    local results = base.Source.collect(self, payload)

    tabler.extend(_collect(payload), results)

    return results
end


function M.Source:new()
    -- TODO: I have no idea what I'm doing. Fix
    local instance = base.Source.new(instance)
    instance.get_icon = M.Source.get_icon
    instance.get_name = M.Source.get_name
    instance.collect = M.Source.collect

    return instance
end


return M
