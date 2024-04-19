-- Some visual niceties for notebooks
-- vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
-- 	group = vim.api.nvim_create_augroup("NotebookVisuals", { clear = true }),
-- 	pattern = { "*.ipynb", "*.Rmd" },
-- 	callback = function()
-- 		local bufnr = vim.api.nvim_get_current_buf()
--
-- 		local function set_extmarks(namespace, pattern, hl_group, symbol)
-- 			if not pcall(vim.cmd, "silent vimgrep /" .. pattern .. "/gj %") then
-- 				return
-- 			end
--
-- 			local quickfix_list = vim.fn.getqflist()
-- 			local space = vim.api.nvim_create_namespace(namespace)
--
-- 			for _, item in ipairs(quickfix_list) do
-- 				vim.api.nvim_buf_set_extmark(bufnr, space, item.lnum - 1, 0, {
-- 					virt_text = {
-- 						{
-- 							symbol,
-- 							hl_group,
-- 						},
-- 					},
-- 					virt_text_pos = "overlay",
-- 				})
-- 			end
-- 		end
--
-- 		set_extmarks("MarkdownCells", "<!--", "Comment", string.rep(" ", 80))
-- 		set_extmarks(
-- 			"PythonCells",
-- 			"```",
-- 			"Comment",
-- 			"━━━━━━━━━━━━━━━━" .. string.rep(" ", 80)
-- 		)
-- 		vim.fn.setqflist({}, "r")
-- 	end,
-- })

vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("codeblocks_namespace", { clear = true }),
	pattern = { "*.md", "*.Rmd" },
	callback = function()
		local _, code_query = pcall(
			vim.treesitter.query.parse,
			"markdown",
			[[
                (code_fence_content)  @codeblock
            ]]
		)

		local function dim_codeblocks(bufnr, query)
			local language_tree = vim.treesitter.get_parser(bufnr, "markdown")
			local syntax_tree = language_tree:parse()
			local root = syntax_tree[1]:root()
			for _, match in query:iter_matches(root, bufnr) do
				for id, node in pairs(match) do
					local capture = query.captures[id]
					if capture == "codeblock" then
						local start_row, _, end_row, _ = node:range()
						vim.api.nvim_buf_set_extmark(
							bufnr,
							vim.api.nvim_create_namespace("codeblocks_namespace"),
							start_row,
							0,
							{
								end_row = end_row,
								hl_group = "CursorColumn",
								hl_eol = true,
							}
						)
					end
				end
			end
		end
		dim_codeblocks(0, code_query)
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("HighlightOnYank", { clear = true }),
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ timeout = 100 })
	end,
})

vim.api.nvim_create_autocmd({ "TermOpen" }, {
	group = vim.api.nvim_create_augroup("StartTerm", { clear = true }),
	pattern = "*",
	callback = function()
		vim.cmd.startinsert()
	end,
})

vim.api.nvim_create_autocmd({ "TermEnter" }, {
	group = vim.api.nvim_create_augroup("TermVisuals", { clear = true }),
	pattern = "*",
	callback = function()
		vim.opt_local.signcolumn = "no"
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
	end,
})

vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdwinEnter" }, {
	callback = function()
		vim.cmd("redir @z")
	end,
})

vim.keymap.set("n", "<C-Enter>", function()
	local output = vim.fn.getreg("z")
	local output = vim.split(output, "\n", { plain = true })
	if vim.tbl_isempty(output) then
		vim.notify("No cmd output to display", vim.log.levels.WARN)
	end
	local scratch_buffer = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_open_win(scratch_buffer, true, {
		split = "below",
		height = 10,
		win = 0,
		style = "minimal",
	})
	vim.api.nvim_buf_set_lines(scratch_buffer, 0, -1, false, output)
	vim.bo[scratch_buffer].modifiable = false
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(0, true)
	end, { buffer = scratch_buffer, nowait = true, noremap = true, silent = true })
end)
