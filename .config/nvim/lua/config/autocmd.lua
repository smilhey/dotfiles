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

local status_group = vim.api.nvim_create_augroup("StatusDisappear", { clear = true })

vim.api.nvim_create_autocmd("CmdwinEnter", {
	group = status_group,
	callback = function()
		vim.cmd("startinsert")
	end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	callback = function()
		if vim.fn.win_gettype() ~= "" or vim.bo.filetype == "MsgArea" or vim.bo.filetype == "Zen" then
			return
		end
		vim.opt_local.winbar = "%#StatusLine# %n %*%=%m %f"
	end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	callback = function()
		vim.cmd("silent! normal! g'\"")
	end,
})

vim.api.nvim_create_autocmd("Filetype", {
	pattern = { "help", "qf", "query" },
	callback = function()
		vim.keymap.set(
			"n",
			"q",
			"<cmd>close<CR>",
			{ desc = "Close no file/temporary windows", silent = true, nowait = true, buffer = true }
		)
	end,
})

vim.api.nvim_create_autocmd("CmdwinEnter", {
	callback = function()
		local type = vim.fn.getcmdwintype()
		if type == "/" or type == "?" then
			vim.o.hlsearch = true
			vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP" }, {
				buffer = 0,
				callback = function()
					vim.fn.setreg("/", vim.fn.getline("."))
				end,
			})
		end
	end,
})

vim.api.nvim_create_autocmd("CmdwinLeave", {
	callback = function()
		local type = vim.fn.getcmdwintype()
		if type == "/" or type == "?" then
			vim.o.hlsearch = false
		end
	end,
})
