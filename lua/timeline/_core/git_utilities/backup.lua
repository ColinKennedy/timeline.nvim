local constant = require("timeline._core.constant")
local filer = require("timeline._core.vim_utilities.filer")
local git_parser = require("timeline._core.git_utilities.git_parser")
local terminal = require("timeline._core.vim_utilities.terminal")
local version = require("timeline._core.version")


local M = {}

local _GROUP_NAME = "TimelineGitBackupGroup"
local _GROUP = vim.api.nvim_create_augroup(_GROUP_NAME, { clear = true })


local function _initialize_root(root)
    if vim.fn.isdirectory(root) ~= 1
    then
        vim.fn.mkdir(root, "p")
    end

    local command = {"git", "init"}
    local options = {cwd=root}
    local success, stdout, _ = terminal.run(command, options)

    if not success
    then
        vim.api.nvim_err_writeln(
            string.format(
                'Command "%s" from directory "%s" failed to run. Error: "%s"',
                vim.inspect(command),
                root,
                table.concat(stdout, "\n")
            )
        )

        return
    end

    terminal.run(
        {"git", "config", "--local", "user.email", "timeline.nvim@noemail.com"},
        options
    )
    terminal.run({"git", "config", "--local", "user.name", "timeline.nvim"}, options)
end


function M.backup_file(root, buffer, record_type)
    _initialize_root(root)

    local source_path = vim.fn.fnamemodify(vim.fn.bufname(buffer), ":p")
    local repository_path = filer.join_path(
        {
            root,
            git_parser.get_repository_path(source_path),
        }
    )

    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
    local directory = vim.fn.fnamemodify(repository_path, ":h")

    if vim.fn.isdirectory(directory) ~= 1
    then
        vim.fn.mkdir(directory, "p")
    end

    vim.fn.writefile(lines, repository_path, "b")

    local command = string.format('git add "%s"', repository_path)
    local success, stdout, _ = terminal.run(command, {cwd=root})

    if not success
    then
        vim.api.nvim_err_writeln(
            string.format(
                'Command "%s" from directory "%s" failed to run. Error: "%s"',
                command,
                root,
                table.concat(stdout, "\n")
            )
        )

        return
    end

    local message = "Updated file"  -- TODO: Add a more meaningful message
    command = string.format('git commit -m "%s"', message)
    success, stdout, _ = terminal.run(command, {cwd=root})

    if not success
    then
        vim.api.nvim_err_writeln(
            string.format(
                'Command "%s" from directory "%s" failed to run. Error: "%s"',
                command,
                root,
                vim.inspect(stdout)
            )
        )

        return
    end

    command = string.format(
        "git notes add -m \'%s\'",
        vim.fn.json_encode(
            {
                record_type = record_type,
                timeline_version = version.VERSION,
            }
        )
    )
    success, stdout, _ = terminal.run(command, {cwd=root})

    if not success
    then
        vim.api.nvim_err_writeln(
            string.format(
                'Command "%s" from directory "%s" failed to run. Error: "%s"',
                command,
                root,
                table.concat(stdout, "\n")
            )
        )

        return
    end
end


function M.setup(root)
    vim.cmd(":autocmd! " .. _GROUP_NAME .. " BufWritePost")

    vim.api.nvim_create_autocmd(
        { "BufWritePost" },
        {
            callback = function ()
                local buffer = vim.fn.bufnr()

                -- Important: We schedule the backup to later in Neovim's execution.
                --
                -- The "Restore" source needs to commit to the same repository
                -- to where "File Save" goes to. So the "File Save" is
                -- effectively treated like a backup commit, in case no other
                -- action / source touches a file first.
                --
                vim.schedule(
                    function()
                        M.backup_file(root, buffer, constant.RecordTypes.file_save)
                    end
                )
            end,
            group = _GROUP,
        }
    )
end


return M
