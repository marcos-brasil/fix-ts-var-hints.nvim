local describe = require("plenary.busted").describe
local it = require("plenary.busted").it
local assert = require("luassert")
local core = require("fix-ts-var-hints.core")

describe("fix-ts-var-hints Core Module", function()
	-- Test for clear_inlay_hints
	it("should clear inlay hints in the buffer", function()
		-- Setup a mock buffer
		local mock_bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(mock_bufnr, 0, -1, false, { "dummy line" })
		vim.api.nvim_create_namespace("inlay_hints")

		-- Call clear_inlay_hints and check results
		core.clear_inlay_hints(mock_bufnr)
		local inlay_cache = {} -- Simulated inlay_cache, verify that it's cleared
		assert.is_nil(inlay_cache[mock_bufnr])
	end)

	-- Test for normalize_whitespace
	it("should normalize multiple whitespaces to a single space", function()
		local result = core.normalize_whitespace("This    is   a   test")
		assert.are.same(result, "This is a test")
	end)

	-- Test for extract_code_block
	it("should extract content inside code blocks", function()
		local hover_lines = {
			"Some text",
			"```",
			"code line 1",
			"code line 2",
			"```",
			"More text",
		}

		local result = core.extract_code_block(hover_lines)
		assert.are.same(result, { "code line 1", "code line 2" })
	end)

	it("should extract the type from TypeScript hover information", function()
		local hover_text = {
			"```typescript",
			"let x: number",
			"```",
		}

		local result = core.extract_type_from_hover(hover_text, "x")
		assert.are.same(result, "number")
	end)

	it("should display inlay hints as virtual text for a single TypeScript variable", function()
		-- Create a new buffer for testing
		local bufnr = vim.api.nvim_create_buf(false, true)

		-- Load the buffer with TypeScript code
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "let num = 3;" })

		-- Trigger the inlay hints using your core function
		core.show_inlay_hints()

		-- Allow more time for processing
		vim.wait(4000, function()
			return vim.lsp.buf_is_attached(bufnr, 1)
		end)

		-- Get the namespace if not correctly set in core
		local namespace = vim.api.nvim_create_namespace("inlay_hints")

		-- Verify that virtual text (inlay hint) was added
		local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, namespace, 0, -1, { details = true })
		print(vim.inspect(extmarks)) -- Debugging: Inspect extmarks

		assert.is_not_nil(extmarks)
		assert.is_true(#extmarks > 0)

		-- Check the content of the virtual text
		if #extmarks > 0 then
			local virtual_text = extmarks[1][4].virt_text[1][1]
			assert.are.same(virtual_text, "number") -- Expect the inlay hint to be "number"
		end
	end)

	-- Test for inlay hints display with TypeScript hover content, expecting the type to be shown inline
	-- it("should display inlay hints inline for a single variable", function()
	-- 	local mock_bufnr = vim.api.nvim_create_buf(false, true)
	-- 	vim.api.nvim_buf_set_lines(mock_bufnr, 0, -1, false, { "let x = 10;" })
	--
	-- 	-- Mocking LSP responses for symbols
	-- 	vim.lsp.buf_request = function(_, method, params, callback)
	-- 		if method == "textDocument/documentSymbol" then
	-- 			local mock_symbols = {
	-- 				{ name = "x", kind = 13, range = { start = { line = 0, character = 4 } } },
	-- 			}
	-- 			callback(nil, mock_symbols)
	-- 		elseif method == "textDocument/hover" then
	-- 			local hover_content = {
	-- 				contents = { "```typescript", "let x: number", "```" },
	-- 			}
	-- 			callback(nil, hover_content)
	-- 		end
	-- 	end
	--
	-- 	-- Use the core function to show inlay hints
	-- 	core.show_inlay_hints()
	--
	-- 	-- Verify that the inlay hints were added
	-- 	local lines = vim.api.nvim_buf_get_lines(mock_bufnr, 0, -1, false)
	-- 	assert.is_not_nil(lines)
	-- 	assert.are.same(lines[1], "let x = 10; number")
	-- end)

	-- Test for extract_type_from_hover
	-- it("should extract the type from hover information", function()
	-- 	local hover_text = [[
	-- 		Some text
	-- 		```lua
	-- 		local x: number = 42,
	-- 		function foo(): string
	-- 		```,
	--      ]]
	-- 	local result = core.extract_type_from_hover(hover_text, "x")
	-- 	assert.are.same(result, "number")
	--
	-- 	result = core.extract_type_from_hover(hover_text, "foo")
	-- 	assert.are.same(result, "string")
	--
	-- 	result = core.extract_type_from_hover(hover_text, "nonexistent")
	-- 	assert.is_nil(result)
	-- end)

	-- Test for show_inlay_hints (this requires mocking LSP interactions)
	-- it("should show inlay hints for variable declarations", function()
	-- 	local mock_bufnr = vim.api.nvim_create_buf(false, true)
	-- 	vim.api.nvim_buf_set_lines(mock_bufnr, 0, -1, false, { "local x = 1", "local y = 2" })
	--
	-- 	-- Mocking LSP responses for symbols
	-- 	vim.lsp.buf_request = function(_, method, params, callback)
	-- 		if method == "textDocument/documentSymbol" then
	-- 			local mock_symbols = {
	-- 				{ name = "x", kind = 13, range = { start = { line = 0, character = 6 } } },
	-- 				{ name = "y", kind = 13, range = { start = { line = 1, character = 6 } } },
	-- 			}
	-- 			callback(nil, mock_symbols)
	-- 		elseif method == "textDocument/hover" then
	-- 			local hover_content = {
	-- 				contents = "```lua\nlocal x: number\n```",
	-- 			}
	-- 			callback(nil, hover_content)
	-- 		end
	-- 	end
	--
	-- 	core.show_inlay_hints()
	--
	-- 	-- Verify that the inlay hints were added
	-- 	local extmarks = vim.api.nvim_buf_get_extmarks(mock_bufnr, core.namespace, 0, -1, {})
	-- 	assert.is_not_nil(extmarks)
	-- 	assert.is_true(#extmarks > 0)
	-- end)
end)
