local M = {}


local function _get_window_location_list(window)
    local data = getloclist(window)

    if vim.tbl_isempty(data)
    then
        return nil
    end

    return data
end


local function _get_quick_fix_list()
    local data = getqflist()

    if vim.tbl_isempty(data)
    then
        return nil
    end

    return data
end


function M.tests_ran(details)
    details = (
        details
        or _get_current_window_location_list(vim.fn.win_getid())
        or _get_quick_fix_list()
    )

    if details == nil
    then
        vim.api.nvim_err_writeln("No test details could be found. Cannot continue.")

        return
    end

    configuration.DATA.backup_repository_path
end


return M
