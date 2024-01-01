local filer = require("timeline._core.vim_utilities.filer")
local tabler = require("timeline._core.vim_utilities.tabler")
local terminal = require("timeline._core.vim_utilities.terminal")
local text_mate = require("timeline._core.vim_utilities.text_mate")


local M = {}


function M.get_commit_datetime(commit, repository)
    local command = string.format("git show --no-patch --format=%%ct %s", commit)
    local success, stdout, stderr = unpack(terminal.run(command, {cwd=repository}))

    if not success
    then
        vim.api.nvim_err_writeln(string.format('Command "%s" failed to run.', command))
        vim.api.nvim_err_writeln(stderr)

        return nil
    end

    stdout = tabler.filter_item("", stdout)

    return tonumber(stdout[1])
end


function M.get_commit_text(path, repository, commit)
    local template = "git show %s:%s"
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


function M.get_latest_changes(repository, path, start_index, end_index)
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

    stdout = tabler.filter_item("", stdout)

    return stdout
end


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


function M.get_repository_path(path)
    local stripped = filer.lstrip_path(path)
    local repository_relative_path = filer.join_path({vim.fn.hostname(), stripped})

    return repository_relative_path
end


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


return M
