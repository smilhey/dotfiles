local function win_select(items, opts, on_choice, win_opts)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"

	local prompt = opts.prompt or ""
	local format_item = opts.format_item
	local string_items = vim.tbl_map(function(item)
		return format_item(item)
	end, items)
	local win_width = math.max(unpack(vim.tbl_map(function(string)
		return #string
	end, string_items)))
	win_width = math.max(win_width, #prompt)
	local win_height = #items > 0 and #items or 1

	local default_win_opts = {
		relative = "editor",
		row = vim.o.lines / 2 - math.ceil(win_height / 2),
		col = vim.o.columns / 2 - math.ceil(win_width / 2),
		width = win_width > 20 and math.ceil(win_width) or 20,
		height = win_height,
		focusable = true,
		style = "minimal",
		border = "single",
		title = prompt,
	}
	win_opts = vim.tbl_deep_extend("force", default_win_opts, win_opts)
	local win = vim.api.nvim_open_win(buf, true, win_opts)
	vim.wo[win].winhighlight = "lCursor:"
	vim.wo[win].signcolumn = "no"
	vim.wo[win].cursorline = true
	vim.wo[win].cursorlineopt = "line"
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, string_items)
	vim.bo[buf].modifiable = false

	vim.keymap.set("n", "q", "<cmd>close!<CR>", { noremap = true, nowait = true, buffer = buf })
	vim.keymap.set("n", "<CR>", function()
		local choice = items[vim.api.nvim_win_get_cursor(win)[1]]
		on_choice(choice)
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf, noremap = true, nowait = true })
end

vim.ui.select = function(items, opts, on_choice)
	win_select(items, opts, on_choice, {})
end
