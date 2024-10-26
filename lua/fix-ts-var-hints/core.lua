local M = {}

-- Namespace for inlay hints
local namespace = vim.api.nvim_create_namespace("inlay_hints")
local inlay_cache = {} -- Cache to store inlay hints by line number

-- Function to clear all inlay hints in the buffer
function M.clear_inlay_hints(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
	inlay_cache[bufnr] = {} -- Clear the cache for the current buffer
end

-- Helper function to normalize whitespace
function M.normalize_whitespace(text)
	return text:gsub("%s+", " ")
end

-- Helper function to extract content within code blocks
function M.extract_code_block(hover_lines)
	local inside_code_block = false
	local code_content = {}

	for _, line in ipairs(hover_lines) do
		if line:match("^```") then
			inside_code_block = not inside_code_block
		elseif inside_code_block then
			table.insert(code_content, line)
		end
	end

	return code_content
end

-- Helper function to extract the type right after the variable name
function M.extract_type_from_hover(hover_text, variable_name)
	local code_block_content = M.extract_code_block(hover_text)
	local cleaned_text = table.concat(code_block_content, " ")
	cleaned_text = M.normalize_whitespace(cleaned_text)
	local type_info = cleaned_text:match(variable_name .. "%s*:%s*(.*)")

	if type_info and type_info:match("^%s*%(") then
		return nil
	end

	return type_info
end

-- Function to get symbols from the document and show inlay hints for variable declarations
function M.show_inlay_hints()
	local bufnr = vim.api.nvim_get_current_buf()

	if not inlay_cache[bufnr] then
		inlay_cache[bufnr] = {}
	end

	M.clear_inlay_hints(bufnr)

	vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", {
		textDocument = vim.lsp.util.make_text_document_params(),
	}, function(_, result, _, _)
		if not result then
			return
		end

		function M.handle_symbols(symbols)
			for _, symbol in ipairs(symbols) do
				if symbol.kind == 13 or symbol.kind == 6 then
					local range = symbol.location and symbol.location.range or symbol.range
					if range then
						local row = range.start.line
						local col = range.start.character
						local variable_name = symbol.name

						vim.lsp.buf_request(bufnr, "textDocument/hover", {
							textDocument = vim.lsp.util.make_text_document_params(),
							position = { line = row, character = col },
						}, function(_, hover_result, _, _)
							if not (hover_result and hover_result.contents) then
								return
							end

							local hover_text = vim.lsp.util.convert_input_to_markdown_lines(hover_result.contents)
							local type_info = M.extract_type_from_hover(hover_text, variable_name)

							if not type_info then
								return
							end

							if inlay_cache[bufnr][row] == type_info then
								return
							end

							local normalized_cached_hint = M.normalize_whitespace(inlay_cache[bufnr][row] or "")
							local normalized_current_hint = M.normalize_whitespace(type_info or "")

							if normalized_cached_hint == normalized_current_hint then
								return
							end

							inlay_cache[bufnr] = inlay_cache[bufnr] or {}
							inlay_cache[bufnr][row] = type_info

							vim.api.nvim_buf_set_extmark(bufnr, namespace, row, 0, {
								virt_text = { { type_info, "Comment" } },
								hl_mode = "combine",
							})
						end)
					end
				end

				if symbol.children then
					M.handle_symbols(symbol.children)
				end
			end
		end

		M.handle_symbols(result)
	end)
end

return M
