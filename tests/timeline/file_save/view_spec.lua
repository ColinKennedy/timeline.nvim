local filer = require("timeline._core.vim_utilities.filer")
local terminal = require("timeline._core.vim_utilities.terminal")
local timeline = require("timeline")
local viewer = require("timeline.viewer")


--- Create a new git repository + directory
---
--- @return string The full path to the root of the git repository.
---
local function _make_empty_git_repository()
    local directory = vim.fn.tempname()
    vim.fn.mkdir(directory, "p")

    terminal.run("git init", {cwd=repository})

    return directory
end


local function _make_git_repository_with_file_saves()
    local directory = vim.fn.tempname()
    vim.fn.mkdir(directory, "p")

    terminal.run("git init", {cwd=repository})
    path = filer.join_path({directory, "file.txt"})

    vim.fn.writefile({}, path, "b")
    terminal.run(string.format("git add '%s'", path), {cwd=repository})
    terminal.run("git commit -m 'Initial commit'", {cwd=repository})

    vim.fn.writefile({"a", "b"}, path, "b")
    terminal.run(string.format("git add '%s'", path), {cwd=repository})
    terminal.run("git commit -m 'Added lines'", {cwd=repository})

    vim.fn.writefile({"c", "b"}, path, "b")
    terminal.run(string.format("git add '%s'", path), {cwd=repository})
    terminal.run("git commit -m 'Changed a line'", {cwd=repository})

    return {directory, path}
end


describe("initialization", function()
    before_each(timeline.setup)

    it("should allow empty repositories", function()
        local repository = _make_empty_git_repository()
        vim.cmd.enew()
        vim.cmd.file("path.txt")

        viewer.view_window(vim.fn.win_getid())

        local file_type = vim.api.nvim_buf_get_option(vim.fn.bufnr(), "filetype")
        assert.equals("timeline_viewer", file_type)
    end)

    it("should work with multiple file save records", function()
        local repository, name = unpack(_make_git_repository_with_file_saves())
        vim.cmd.enew()
        vim.cmd.file(name)

        viewer.view_window(vim.fn.win_getid())

        local file_type = vim.api.nvim_buf_get_option(vim.fn.bufnr(), "filetype")
        assert.equals("timeline_viewer", file_type)
    end)
end)
