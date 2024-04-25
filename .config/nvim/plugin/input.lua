local function custom_input(opts, on_confirm, win_opts)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].buftype = "prompt"
	vim.bo[buf].bufhidden = "wipe"
	vim.keymap.set("n", "q", "<cmd>close!<CR>", { noremap = true, nowait = true, buffer = buf })

	local prompt = opts.prompt or ""
	local default_text = opts.default or ""
	vim.fn.prompt_setprompt(buf, "> ")

	local default_win_opts = {
		relative = "editor",
		row = vim.o.lines / 2 - 1,
		col = vim.o.columns / 2 - 25,
		width = #default_text + #prompt + 5 < 20 and 20 or #default_text + #prompt + 5,
		height = 1,
		focusable = true,
		style = "minimal",
		border = "single",
		title = prompt,
	}
	win_opts = vim.tbl_deep_extend("force", default_win_opts, win_opts)
	local win = vim.api.nvim_open_win(buf, true, win_opts)
	vim.wo[win].winhighlight = "Search:None"

	vim.fn.prompt_setcallback(buf, function(input)
		vim.api.nvim_win_close(win, true)
		on_confirm(input)
	end)

	vim.cmd("startinsert")
	vim.defer_fn(function()
		vim.api.nvim_buf_set_text(buf, 0, 2, 0, 2, { default_text })
		vim.cmd("startinsert!")
	end, 5)
end

vim.ui.input = function(opts, on_confirm)
	custom_input(opts, on_confirm, { relative = "cursor", row = 1, col = 1 })
end
