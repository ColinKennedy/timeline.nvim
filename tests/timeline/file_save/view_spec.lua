local filer = require("timeline._core.vim_utilities.filer")
local terminal = require("timeline._core.vim_utilities.terminal")
local timeline = require("timeline")
local viewer = require("timeline.viewer")


--- Create a new git repository + directory
---
--- @return string # The full path to the root of the git repository.
---
local function _make_empty_git_repository()
    local directory = vim.fn.tempname()
    vim.fn.mkdir(directory, "p")

    terminal.run("git init", {cwd=directory})
end


--- Create a git repository with some existing File Save commits included.
---
--- @return string # The full path to the root of the git repository.
---
local function _make_git_repository_with_file_saves()
    local directory = vim.fn.tempname()
    vim.fn.mkdir(directory, "p")

    terminal.run("git init", {cwd=directory})
    local path = filer.join_path({directory, "file.txt"})

    vim.fn.writefile({}, path, "b")
    terminal.run(string.format("git add '%s'", path), {cwd=directory})
    terminal.run("git commit -m 'Initial commit'", {cwd=directory})

    vim.fn.writefile({"a", "b"}, path, "b")
    terminal.run(string.format("git add '%s'", path), {cwd=directory})
    terminal.run("git commit -m 'Added lines'", {cwd=directory})

    vim.fn.writefile({"c", "b"}, path, "b")
    terminal.run(string.format("git add '%s'", path), {cwd=directory})
    terminal.run("git commit -m 'Changed a line'", {cwd=directory})

    return path
end


describe("initialization", function()
    before_each(timeline.setup)

    it("should allow empty repositories", function()
        _make_empty_git_repository()
        vim.cmd.enew()
        vim.cmd.file("path.txt")

        viewer.view_window(vim.fn.win_getid())

        local file_type = vim.api.nvim_buf_get_option(vim.fn.bufnr(), "filetype")
        assert.equals("timeline_viewer", file_type)
    end)

    it("should work with multiple file save records", function()
        local name = _make_git_repository_with_file_saves()
        vim.cmd.enew()
        vim.cmd.file(name)

        viewer.view_window(vim.fn.win_getid())

        local file_type = vim.api.nvim_buf_get_option(vim.fn.bufnr(), "filetype")
        assert.equals("timeline_viewer", file_type)
        assert.equals(
            3,
            vim.fn.line("$", vim.fn.bufwinid(vim.fn.bufnr()))
        )
    end)
end)


describe("actions - open", function()
    before_each(timeline.setup)

    it("should work in normal mode", function()
        local name = _make_git_repository_with_file_saves()
        vim.cmd.enew()
        vim.cmd.file(name)

        viewer.view_window(vim.fn.win_getid())

        -- TODO: Fix. Not working!
        vim.api.nvim_feedkeys("<leader>o", "m", false)

        local file_type = vim.api.nvim_buf_get_option(vim.fn.bufnr(), "filetype")
        assert.equals("foobar", file_type)
    end)
end)
