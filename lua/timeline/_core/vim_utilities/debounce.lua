local M = {}


--- @source https://gist.github.com/runiq/31aa5c4bf00f8e0843cd267880117201#debouncing-on-the-leading-edge
function M.debounce_trailing(caller, milliseconds, first)
    local timer = vim.loop.new_timer()
    local wrapped_function

    if not first then
        function wrapped_function(...)
            local argv = {...}
            local argc = select('#', ...)

            timer:start(
                milliseconds,
                0,
                function() pcall(vim.schedule_wrap(caller), unpack(argv, 1, argc)) end
            )
        end
    else
        local argv, argc

        function wrapped_function(...)
            argv = argv or {...}
            argc = argc or select('#', ...)

            timer:start(
                milliseconds,
                0,
                function() pcall(vim.schedule_wrap(caller), unpack(argv, 1, argc)) end
            )
        end
    end

    return wrapped_function, timer
end


return M
