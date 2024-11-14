local M = { ns = vim.api.nvim_create_namespace("input") }

local default_win_opts = {
	relative = "editor",
	row = math.floor(vim.o.lines / 5),
	col = math.floor((2 * vim.o.columns / 6)),
	width = math.ceil(vim.o.columns / 3),
	height = 1,
	focusable = true,
	style = "minimal",
	border = "single",
}

function M.win_input(opts, on_confirm, win_opts)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].buftype = "nofile"
	vim.keymap.set("n", "<C-C>", "<cmd>close!<CR>", { buffer = buf })
	if opts.completion then
		M.completion = opts.completion
		vim.bo[buf].completefunc = "v:lua.require'ui.input'.completefunc"
		vim.keymap.set("i", "<Tab>", function()
			return vim.fn.pumvisible() == 1 and "<C-n>" or "<C-x><C-u>"
		end, { buffer = buf, expr = true, desc = "Trigger pum" })
	end

	win_opts = vim.tbl_deep_extend("force", default_win_opts, win_opts)
	win_opts.title = opts.prompt and (" %s "):format(opts.prompt) or ""
	local win = vim.api.nvim_open_win(buf, true, win_opts)
	vim.wo[win].winhighlight = "Search:None"
	vim.wo[win].winfixbuf = true
	vim.wo[win].statuscolumn = " %#" .. "String" .. "#" .. "> "
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { opts.default or "" })
	vim.api.nvim_win_set_cursor(win, { 1, #(opts.default or "") })
	vim.cmd("startinsert!")
	vim.keymap.set({ "n", "i" }, "<CR>", function()
		vim.cmd("stopinsert")
		local line = vim.fn.line(".", win)
		local text = vim.api.nvim_buf_get_lines(buf, line - 1, line, true)[1]
		on_confirm(text)
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf })
end

function M.completefunc(findstart, base)
	if findstart == 1 then
		return -1
	end
	base = vim.api.nvim_buf_get_lines(0, vim.fn.line(".") - 1, vim.fn.line("."), true)[1]
	local pieces = vim.split(M.completion, ",", { plain = true })
	if pieces[1] == "custom" or pieces[1] == "customlist" then
		local vimfunc = pieces[2]
		local ret
		if vim.startswith(vimfunc, "v:lua.") then
			local load_func = string.format("return %s(...)", vimfunc:sub(7))
			local luafunc, err = loadstring(load_func)
			if not luafunc then
				vim.api.nvim_err_writeln(string.format("Could not find completion function %s: %s", vimfunc, err))
				return {}
			end
			ret = luafunc(base, base, vim.fn.strlen(base))
		else
			ret = vim.fn[vimfunc](base, base, vim.fn.strlen(base))
		end
		if pieces[1] == "custom" then
			ret = vim.split(ret, "\n", { plain = true })
		end
		return ret
	end
	local ok, result = pcall(vim.fn.getcompletion, base, M.completion)
	if ok then
		return result
	else
		vim.api.nvim_err_writeln(string.format("ui/input: unsupported completion method '%s'", M.completion))
		return {}
	end
end

return M
