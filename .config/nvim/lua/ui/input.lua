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
	vim.keymap.set(
		"n",
		"<C-C>",
		"<cmd>close!<CR>",
		{ noremap = true, nowait = true, buffer = buf, desc = "Close input window" }
	)
	vim.keymap.set("i", "<Tab>", function()
		print("hello")
		return vim.fn.pumvisible() == 1 and "<C-n>" or "<C-x><C-u>"
	end, { buffer = buf, expr = true, desc = "Trigger pum" })

	local prompt = opts.prompt or ""
	local default_text = opts.default or ""
	local completion = opts.completion

	win_opts = vim.tbl_deep_extend("force", default_win_opts, win_opts)
	win_opts.title = prompt
	local win = vim.api.nvim_open_win(buf, true, win_opts)
	vim.wo[win].winhighlight = "Search:None"
	vim.wo[win].winfixbuf = true
	-- vim.wo[win].virtualedit = "all,onemore"

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { default_text })
	vim.api.nvim_buf_set_extmark(
		buf,
		M.ns,
		0,
		0,
		{ right_gravity = false, virt_text = { { "> ", "Normal" } }, virt_text_pos = "inline" }
	)
	vim.api.nvim_win_set_cursor(win, { 1, #default_text })
	vim.cmd("startinsert!")
	vim.keymap.set({ "n", "i" }, "<CR>", function()
		local text = vim.api.nvim_buf_get_lines(buf, 0, 1, true)[1]
		on_confirm(text)
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf, desc = "Execute on_confirm callback" })

	if completion then
		M.completion = completion
		vim.bo[buf].completefunc = "v:lua.require'ui.input'.completefunc"
	end
end

function M.completefunc(findstart, base)
	if not M.completion then
		return findstart == 1 and 0 or {}
	end
	if findstart == 1 then
		return 0
	else
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
		else
			local ok, result = pcall(vim.fn.getcompletion, base, M.completion)
			if ok then
				vim.schedule(function()
					P("base : " .. base)
				end)
				if base:sub(-1) == " " then
					return vim.tbl_map(function(item)
						return base .. item
					end, result)
				else
					return result
				end
			else
				vim.api.nvim_err_writeln(string.format("ui/input: unsupported completion method '%s'", M.completion))
				return {}
			end
		end
	end
end

return M
