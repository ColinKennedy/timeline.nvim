--- A module for deferring the execution of function calls. Very fancy!
---
--- @module 'timeline._core.vim_utilities.debounce'
---

local M = {}


--- Create a special caller that only runs once after `milliseconds` has elapsed.
---
--- @source https://gist.github.com/runiq/31aa5c4bf00f8e0843cd267880117201#debouncing-on-the-leading-edge
---
--- ::
---
---     local caller = debounce_trailing(function() print("do it") end, 1000)
---     caller()
---     caller()
---     caller()
---     caller()
---     -- Even though `caller` was called 4 times, Neovim will only call it
---     -- once, after 1000 milliseconds (one second)
---
--- @param caller func(): nil
---     Some function to call after `milliseconds` is up.
--- @param milliseconds number
---     The time to wait for before `caller` runs. If `caller` runs before
---     `milliseconds` has completed, the timer is restart again. 1000 == 1 second.
--- @param first boolean
---     If `true`, when `caller` runs, only the last arguments are used.
---     Otherwise, the arguments from the first time it's called are used instaed.
--- @return table<fun(): nil, vim.loop.new_timer()> # asfaf
---
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
