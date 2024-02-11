-- Some visual niceties for notebooks
vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
	group = vim.api.nvim_create_augroup("NotebookVisuals", { clear = true }),
	pattern = { "*.ipynb", "*.Rmd" },
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()

		local function set_extmarks(namespace, pattern, hl_group)
			if not pcall(vim.cmd, "silent vimgrep /" .. pattern .. "/gj %") then
				return
			end

			local quickfix_list = vim.fn.getqflist()
			local space = vim.api.nvim_create_namespace(namespace)

			for _, item in ipairs(quickfix_list) do
				vim.api.nvim_buf_set_extmark(bufnr, space, item.lnum - 1, 0, {
					virt_text = {
						{
							string.rep("━", 80),
							hl_group,
						},
					},
					virt_text_pos = "overlay",
				})
			end
		end

		set_extmarks("MarkdownCells", "<!--", "Comment")
		set_extmarks("PythonCells", "```", "FloatBorder")
		vim.fn.setqflist({}, "r")
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("HighlightOnYank", { clear = true }),
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ timeout = 100 })
	end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	group = vim.api.nvim_create_augroup("RemapEx", { clear = true }),
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local file_name = vim.fn.expand("%:t")
		if not file_name:match("%.ipynb$") and not file_name:match("%.Rmd$") then
			vim.keymap.set("n", ":", "q:i", { buffer = bufnr })
			vim.keymap.set("n", "?", "q?i", { buffer = bufnr })
			vim.keymap.set("n", "/", "q/i", { buffer = bufnr })

			vim.keymap.set("n", "q:", ":", { buffer = bufnr })
			vim.keymap.set("n", "q?", "?", { buffer = bufnr })
			vim.keymap.set("n", "q/", "/", { buffer = bufnr })
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("wgsl", { clear = true }),
	pattern = "*.wgsl",
	callback = function()
		-- vim.cmd("set filetype=wgsl")
		vim.o.filetype = "wgsl"
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
