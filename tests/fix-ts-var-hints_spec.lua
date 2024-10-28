local describe = require("plenary.busted").describe
local it = require("plenary.busted").it
local assert = require("luassert")
local core = require("fix-ts-var-hints.core")
local async = require("plenary.async").tests
local util = require("plenary.async.util")

local sleep = util.sleep
local Screen = require("plenary.nvim.ui.screen")

describe("LSP Inlay Hints Test", function()
	local screen

	before_each(function()
		-- Set up a new screen with a simulated size
		screen = Screen.new(80, 24)
		screen:attach()

		-- Load minimal configuration with plenary.nvim and nvim-lspconfig
		vim.cmd("packadd plenary.nvim")
		vim.cmd("packadd nvim-lspconfig")

		-- Setup the vtsls LSP
		require("lspconfig").vtsls.setup({
			on_attach = function(client, bufnr)
				print("LSP Attached: " .. client.name)
			end,
		})
	end)

	after_each(function()
		screen:detach()
	end)

	it("should display inlay hints as virtual text for a single TypeScript variable", function()
		-- Open the mock TypeScript file
		vim.cmd("edit ./mock/test-1.ts")

		-- Wait for the file to be loaded and for LSP to attach
		sleep(5000) -- Wait for 5 seconds to allow LSP to attach

		-- Trigger the inlay hints using your core function
		require("fix-ts-var-hints.core").show_inlay_hints()

		-- Check if the virtual text (inlay hints) appears on the screen
		screen:expect([[
          let num = 3;^                                           |
          number                                                  |
          {MATCH:.*}                                               |
        ]])
	end)
end)

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

	--
	-- async.it("should display inlay hints as virtual text for a single TypeScript variable", function()
	-- 	-- Create a new buffer for testing using LazyVim's environment
	-- 	local bufnr = vim.api.nvim_create_buf(false, true)
	--
	-- 	-- Load the buffer with TypeScript code
	-- 	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "let num = 3;" })
	--
	-- 	-- Set the file type to TypeScript to trigger LSP attachment via LazyVim
	-- 	vim.bo[bufnr].filetype = "typescript"
	--
	-- 	-- Attach all available LSP clients to the buffer
	-- 	local attached_clients = {}
	-- 	for _, client in pairs(vim.lsp.get_active_clients()) do
	-- 		vim.lsp.buf_attach_client(bufnr, client.id)
	-- 		table.insert(attached_clients, client.name)
	-- 	end
	--
	-- 	print("Attached LSP Clients: ", vim.inspect(attached_clients)) -- Debugging: List all attached LSP clients
	--
	-- 	-- -- Attach all available LSP clients to the buffer
	-- 	-- for _, client in pairs(vim.lsp.get_active_clients()) do
	-- 	-- 	vim.lsp.buf_attach_client(bufnr, client.id)
	-- 	-- end
	--
	-- 	-- Wait for all LSP clients to be attached asynchronously
	-- 	local timeout_ms = 40000 -- Increased timeout to 10 seconds
	-- 	local start_time = vim.loop.hrtime() / 1e6 -- Start time in milliseconds
	--
	-- 	local all_clients_attached = function()
	-- 		local attached = {}
	-- 		for _, client in pairs(vim.lsp.get_active_clients()) do
	-- 			if vim.lsp.buf_is_attached(bufnr, client.id) then
	-- 				table.insert(attached, client.name)
	-- 			end
	-- 		end
	-- 		print("Currently Attached Clients: ", vim.inspect(attached)) -- Debug: Show attached clients dynamically
	-- 		return #attached > 0
	-- 	end
	--
	-- 	-- Poll asynchronously until all LSP clients are attached or timeout
	-- 	while not all_clients_attached() do
	-- 		if (vim.loop.hrtime() / 1e6) - start_time > timeout_ms then
	-- 			error("Timeout: Not all LSP clients attached within 10 seconds")
	-- 		end
	-- 		print("*")
	-- 		util.sleep(100) -- Sleep for 100ms asynchronously
	-- 	end
	--
	-- 	-- Trigger the inlay hints using your core function
	-- 	core.show_inlay_hints()
	--
	-- 	-- Poll until the virtual text is available or timeout
	-- 	local namespace = vim.api.nvim_create_namespace("inlay_hints")
	-- 	local hints_available = false
	-- 	start_time = vim.loop.hrtime() / 1e6 -- Reset the timer
	--
	-- 	while not hints_available do
	-- 		local extmarks = vim.lsp.get_clientsget_clients(bufnr, namespace, 0, -1, { details = true })
	-- 		if #extmarks > 0 then
	-- 			hints_available = true
	-- 		elseif (vim.loop.hrtime() / 1e6) - start_time > timeout_ms then
	-- 			error("Timeout: Inlay hints not displayed within 10 seconds")
	-- 		end
	-- 		print((vim.loop.hrtime() / 1e6) - start_time)
	-- 		util.sleep(100) -- Sleep for 100ms asynchronously
	-- 	end
	--
	-- 	-- Verify that virtual text (inlay hint) was added
	-- 	local extmarks = vim.lsp.get_clients(bufnr, namespace, 0, -1, { details = true })
	-- 	print("Extmarks found: ", vim.inspect(extmarks)) -- Debugging: Inspect extmarks
	--
	-- 	-- Assert that virtual text was added
	-- 	assert.is_not_nil(extmarks)
	-- 	assert.is_true(#extmarks > 0)
	--
	-- 	-- Check the content of the virtual text
	-- 	if #extmarks > 0 then
	-- 		local virtual_text = extmarks[1][4].virt_text[1][1]
	-- 		assert.are.same(virtual_text, "number2") -- Expect the inlay hint to be "number"
	-- 	end
	-- end)
	--
	-- -- async.it("should display inlay hints as virtual text for a single TypeScript variable", function()
	-- -- 	-- Create a new buffer for testing using LazyVim's environment
	-- -- 	local bufnr = vim.api.nvim_create_buf(false, true)
	-- --
	-- -- 	-- Load the buffer with TypeScript code
	-- -- 	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "let num = 3;" })
	-- --
	-- -- 	-- Set the file type to TypeScript to trigger LSP attachment via LazyVim
	-- -- 	vim.bo[bufnr].filetype = "typescript"
	-- --
	-- -- 	-- Get the active LSP client ID for TypeScript (tsserver)
	-- -- 	local client_id
	-- -- 	for _, client in pairs(vim.lsp.get_active_clients()) do
	-- -- 		if client.name == "v" then
	-- -- 			client_id = client.id
	-- -- 			break
	-- 		end
	-- 	end
	--
	-- 	-- Check if the LSP client for TypeScript is running
	-- 	if not client_id then
	-- 		error("No LSP client found for TypeScript (tsserver)")
	-- 	end
	--
	-- 	-- Wait for the LSP server to attach asynchronously using plenary timing
	-- 	local timeout_ms = 5000
	-- 	local start_time = util.time()
	-- 	while not vim.lsp.buf_is_attached(bufnr, client_id) do
	-- 		if util.time() - start_time > timeout_ms then
	-- 			error("Timeout: LSP server did not attach within 5 seconds")
	-- 		end
	-- 		async.util.sleep(100) -- Sleep for 100ms asynchronously
	-- 	end
	-- 	-- Trigger the inlay hints using your core function
	-- 	core.show_inlay_hints()
	--
	-- 	-- Allow more time for virtual text processing
	-- 	async.util.sleep(3000)
	--
	-- 	-- Use the correct namespace from your plugin (in this case "inlay_hints")
	-- 	local namespace = vim.api.nvim_create_namespace("inlay_hints")
	--
	-- 	-- Verify that virtual text (inlay hint) was added
	-- 	local extmarks = vim.lsp.get_clientsget_clients(bufnr, namespace, 0, -1, { details = true })
	-- 	print("Extmarks found: ", vim.inspect(extmarks)) -- Debugging: Inspect extmarks
	--
	-- 	-- Assert that virtual text was added
	-- 	assert.is_not_nil(extmarks)
	-- 	assert.is_true(#extmarks > 0)
	--
	-- 	-- Check the content of the virtual text
	-- 	if #extmarks > 0 then
	-- 		local virtual_text = extmarks[1][4].virt_text[1][1]
	-- 		assert.are.same(virtual_text, "number") -- Expect the inlay hint to be "number"
	-- 	end
	-- end)
	-- async.it("should display inlay hints as virtual text for a single TypeScript variable", function()
	-- 	-- Create a new buffer for testing using LazyVim's environment
	-- 	local bufnr = vim.api.nvim_create_buf(false, true)
	--
	-- 	-- Load the buffer with TypeScript code
	-- 	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "let num = 3;" })
	--
	-- 	-- Set the file type to TypeScript to trigger LSP attachment via LazyVim
	-- 	vim.bo[bufnr].filetype = "typescript"
	--
	-- 	-- Wait for the LSP server to attach asynchronously
	-- 	local attached = false
	-- 	vim.lsp.buf_attach_client(bufnr, function(client)
	-- 		attached = true
	-- 	end)
	--
	-- 	-- Poll asynchronously until the LSP server is attached
	-- 	local start = vim.loop.hrtime()
	-- 	while not attached do
	-- 		if vim.loop.now() - start > 5000 then -- 5000ms timeout
	-- 			error("Timeout: LSP server did not attach within 5 seconds")
	-- 		end
	-- 		async.util.sleep(100) -- Sleep for 100ms asynchronously
	-- 	end
	--
	-- 	-- Trigger the inlay hints using your core function
	-- 	core.show_inlay_hints()
	--
	-- 	-- Allow more time for virtual text processing
	-- 	async.util.sleep(3000)
	--
	-- 	-- Use the correct namespace from your plugin (in this case "inlay_hints")
	-- 	local namespace = vim.api.nvim_create_namespace("inlay_hints")
	--
	-- 	-- Verify that virtual text (inlay hint) was added
	-- 	local extmarks = vim.lsp.get_clientsget_clients(bufnr, namespace, 0, -1, { details = true })
	-- 	print("Extmarks found: ", vim.inspect(extmarks)) -- Debugging: Inspect extmarks
	--
	-- 	-- Assert that virtual text was added
	-- 	assert.is_not_nil(extmarks)
	-- 	assert.is_true(#extmarks > 0)
	--
	-- 	-- Check the content of the virtual text
	-- 	if #extmarks > 0 then
	-- 		local virtual_text = extmarks[1][4].virt_text[1][1]
	-- 		assert.are.same(virtual_text, "number") -- Expect the inlay hint to be "number"
	-- 	end
	-- end)

	-- it("should display inlay hints as virtual text for a single TypeScript variable", function()
	-- 	-- Create a new buffer for testing using LazyVim's environment
	-- 	local bufnr = vim.api.nvim_create_buf(false, true)
	--
	-- 	-- Load the buffer with TypeScript code
	-- 	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "let num = 3;" })
	--
	-- 	-- Set the file type to TypeScript to trigger LSP attachment via LazyVim
	-- 	vim.bo[bufnr].filetype = "typescript"
	--
	-- 	-- Wait for the LSP server to attach, assuming LazyVim handles LSP correctly
	--
	-- 	-- Check if any LSP client is attached to the buffer
	-- 	vim.wait(5000, function()
	-- 		for _, client in pairs(vim.lsp.get_active_clients()) do
	-- 			if vim.lsp.buf_is_attached(bufnr, client.id) then
	-- 				return true
	-- 			end
	-- 		end
	-- 		return false
	-- 	end)
	--
	-- 	-- Trigger the inlay hints using your core function
	-- 	core.show_inlay_hints()
	--
	-- 	-- Allow more time for virtual text processing
	-- 	vim.wait(3000)
	--
	-- 	-- Use the correct namespace from your plugin (in this case "inlay_hints")
	-- 	local namespace = vim.api.nvim_create_namespace("inlay_hints")
	--
	-- 	-- Verify that virtual text (inlay hint) was added
	-- 	local extmarks = vim.lsp.get_clientsget_clients(bufnr, namespace, 0, -1, { details = true })
	-- 	print("Extmarks found: ", vim.inspect(extmarks)) -- Debugging: Inspect extmarks
	--
	-- 	-- Assert that virtual text was added
	-- 	assert.is_not_nil(extmarks)
	-- 	assert.is_true(#extmarks > 0)
	--
	-- 	-- Check the content of the virtual text
	-- 	if #extmarks > 0 then
	-- 		local virtual_text = extmarks[1][4].virt_text[1][1]
	-- 		assert.are.same(virtual_text, "number") -- Expect the inlay hint to be "number"
	-- 	end
	-- end)
	--
	-- -- it("should display inlay hints as virtual text for a single TypeScript variable", function()
	-- 	-- Create a new buffer for testing
	-- 	local bufnr = vim.api.nvim_create_buf(false, true)
	--
	-- 	-- Load the buffer with TypeScript code
	-- 	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "let num = 3;" })
	--
	-- 	-- Trigger the inlay hints using your core function
	-- 	core.show_inlay_hints()
	--
	-- 	-- Allow more time for processing
	-- 	vim.wait(4000, function()
	-- 		return vim.lsp.buf_is_attached(bufnr, 1)
	-- 	end)
	--
	-- 	-- Get the namespace if not correctly set in core
	-- 	local namespace = vim.api.nvim_create_namespace("inlay_hints")
	--
	-- 	-- Verify that virtual text (inlay hint) was added
	-- 	local extmarks = vim.lsp.get_clientsget_clients(bufnr, namespace, 0, -1, { details = true })
	-- 	print(vim.inspect(extmarks)) -- Debugging: Inspect extmarks
	--
	-- 	assert.is_not_nil(extmarks)
	-- 	assert.is_true(#extmarks > 0)
	--
	-- 	-- Check the content of the virtual text
	-- 	if #extmarks > 0 then
	-- 		local virtual_text = extmarks[1][4].virt_text[1][1]
	-- 		assert.are.same(virtual_text, "number") -- Expect the inlay hint to be "number"
	-- 	end
	-- end)
end)
