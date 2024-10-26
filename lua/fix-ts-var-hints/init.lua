local core = require("fix-ts-var-hints.core")

local M = {}

-- M.setup = function()
--   -- Optionally, users can add configurations here
-- end

-- Expose core functionality
M.show_inlay_hints = core.show_inlay_hints

return M
