print("Loaded init.lua")
-- vim.cmd("packadd plenary.nvim")
-- require("tests.fix-ts-var-hints_spec")

-- Root directory setup
local root_dir = vim.fn.fnamemodify(vim.trim(vim.fn.system("git rev-parse --show-toplevel")), ":p")

-- Adjust Lua module path
package.path = string.format("%s;%s?.lua;%s?/init.lua", package.path, root_dir, root_dir)

-- Set Neovim's 'packpath' to ensure plugins are available
vim.opt.packpath:prepend("~/.local/share/nvim/lazy")

-- Setup runtime path (RTP)
vim.opt.rtp = {
	root_dir,
	"~/.local/share/nvim/lazy/lazy.nvim", -- Path to LazyVim's plugin manager
	vim.env.VIMRUNTIME,
}

-- Load LazyVim configuration
vim.cmd([[
  source ~/.config/nvim/init.lua  -- Adjust this path to your LazyVim config
]])

-- Disable swap files for testing
vim.opt.swapfile = false
