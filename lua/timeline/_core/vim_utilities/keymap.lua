local M = {}


function M.unmap_all(buffer)
    local modes = {"n", "v", "x", "s", "o", "i", "l", "c", "t"}

    for _, mode in ipairs(modes)
    do
        local mappings = vim.api.nvim_buf_get_keymap(buffer, mode)

        for _, mapping in ipairs(mappings)
        do
            vim.api.nvim_buf_del_keymap(buffer, mode, mapping.lhs)
        end
    end
end


return M
