local ts_inlay_hints = require("fix-ts-var-hints")

-- Attach autocommand to update inlay hints when the buffer is changed or cursor moves
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "CursorHold", "InsertLeave", "DiagnosticChanged" }, {
	pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" }, -- TypeScript and JavaScript files
	callback = function()
		ts_inlay_hints.show_inlay_hints()
	end,
})

-- Autocommand to detect text changes and mark the state as changed
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
	pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
	callback = function()
		ts_inlay_hints.show_inlay_hints()
	end,
})
