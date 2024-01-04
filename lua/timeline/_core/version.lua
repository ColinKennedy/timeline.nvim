--- An internally tracked version that is added to `git notes` and commits.
---
--- We may never need to use it for this but having version information written
--- into our baked notes could help with backwards compatibility some day.
---
--- @module 'timeline._core.version'
---

local M = {}


M.VERSION = {1, 0, 0}


return M
