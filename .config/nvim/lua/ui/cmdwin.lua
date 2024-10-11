local ENTER = vim.api.nvim_replace_termcodes("<cr>", true, true, true)
local ESC = vim.api.nvim_replace_termcodes("<esc>", true, true, true)

-- win_opts = {
-- 	relative = "editor",
-- 	zindex = 200,
-- 	row = vim.o.lines,
-- 	col = 0,
-- 	style = "minimal",
-- 	width = vim.o.columns,
-- 	height = 1,
-- },
local M = {
	attached = false,
	mode = "cmd",
	buf = -1,
	win = -1,
	curr_win = -1,
	cmd = nil,
	pos = 0,
	firtc = nil,
	prompt = nil,
	cmdheight = 0,
	win_opts = {
		relative = "editor",
		row = math.floor(vim.o.lines / 5),
		col = math.floor((2 * vim.o.columns / 6)),
		height = 1,
		width = math.ceil(vim.o.columns / 3),
		style = "minimal",
		border = "single",
		zindex = 200,
	},
	history = {},
	opts = { msgarea = false, resize = true },
}

function M.init_buf()
	if vim.api.nvim_buf_is_loaded(M.buf) then
		return
	end
	M.buf = vim.api.nvim_create_buf(false, true)
	-- vim.bo[M.buf].filetype = "vim"
	vim.bo[M.buf].bufhidden = "wipe"
	vim.bo[M.buf].buftype = "nofile"
	vim.api.nvim_buf_set_name(M.buf, "cmdline")
	M.exit_autocmd = vim.api.nvim_create_autocmd({ "BufLeave", "BufHidden" }, { buffer = M.buf, callback = M.exit })
	vim.api.nvim_create_autocmd({ "InsertEnter" }, {
		buffer = M.buf,
		callback = function()
			vim.api.nvim_feedkeys(ESC, "nt", false)
			M.exit_edit()
		end,
	})
	vim.keymap.set("n", "<c-c>", M.exit, { buffer = M.buf })
	vim.keymap.set("n", "<cr>", function()
		local firstc, cmd = M.firstc, vim.api.nvim_get_current_line()
		M.exit()
		M.exe(firstc, cmd)
	end, { silent = true, buffer = M.buf, noremap = true })
end

function M.resize_win()
	if not M.opts.resize then
		return
	end
	local width = math.max(#M.prompt + #M.firstc + #M.cmd + 1, M.win_opts.width)
	local col = math.ceil((vim.o.columns - width) / 2)
	if width ~= vim.api.nvim_win_get_width(M.win) then
		vim.api.nvim_win_set_config(M.win, { relative = "editor", width = width, col = col, row = M.win_opts.row })
	end
end

function M.init_win()
	if not vim.api.nvim_win_is_valid(M.win) then
		M.cmdheight = vim.o.cmdheight
		M.curr_win = vim.api.nvim_get_current_win()
		if M.opts.msgarea and vim.o.cmdheight == 0 then
			vim.cmd("set cmdheight=1")
		end
		M.win = vim.api.nvim_open_win(M.buf, false, M.win_opts)
		vim.wo[M.win].winfixbuf = true
		vim.wo[M.win].virtualedit = "all,onemore"
		vim.api.nvim_win_set_hl_ns(M.win, M.namespace)
		vim.api.nvim__redraw({ cursor = true, flush = true })
	end
	M.resize_win()
end

function M.get_history()
	local len = vim.fn.histnr(M.firstc)
	local history = {}
	for i = 1, len do
		local cmd = vim.fn.histget(M.firstc, i)
		if cmd ~= "" then
			table.insert(history, vim.fn.histget(M.firstc, i))
		end
	end
	return history
end

function M.set_history()
	local history = M.get_history()
	vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, history)
	for i = 1, #history do
		vim.api.nvim_buf_set_extmark(M.buf, M.namespace, i - 1, 0, {
			right_gravity = false,
			virt_text_pos = "inline",
			virt_text = { { M.firstc, "Normal" } },
		})
	end
end

function M.render()
	M.init_buf()
	if not M.firstc or not M.prompt then
		return
	end
	local linenr = vim.api.nvim_buf_line_count(M.buf)
	local cmd_prompt = M.firstc .. (" "):rep(M.indent) .. M.prompt
	if not vim.api.nvim_win_is_valid(M.win) then
		if M.firstc then
			M.set_history()
		end
		-- empty line for extmark
		vim.api.nvim_buf_set_lines(M.buf, -1, -1, false, { "" })
		linenr = vim.api.nvim_buf_line_count(M.buf)
		vim.api.nvim_buf_set_extmark(M.buf, M.namespace, linenr - 1, 0, {
			right_gravity = false,
			virt_text_pos = "inline",
			virt_text = { { cmd_prompt, "Normal" } },
		})
	end
	vim.api.nvim_buf_set_lines(M.buf, -2, -1, false, { M.cmd })
	M.init_win()
	vim.api.nvim_win_set_cursor(M.win, { linenr, M.pos })
	vim.api.nvim__redraw({ flush = true, cursor = true, win = M.win })
end

function M.enter_edit()
	M.mode = "edit"
	vim.api.nvim_feedkeys(ESC, "nt", false)
	vim.api.nvim_set_current_win(M.win)
	M.pos = M.pos > 0 and M.pos - 1 or M.pos
	vim.schedule(function()
		M.render()
	end)
end

function M.exit_edit()
	local curpos = vim.api.nvim_win_get_cursor(M.win)
	M.pos = curpos[2]
	M.cmd = vim.api.nvim_get_current_line()
	-- without the schedule the cursor might be in the wrong position
	vim.schedule(function()
		vim.api.nvim_del_autocmd(M.exit_autocmd)
		vim.api.nvim_set_current_win(M.curr_win)
		vim.api.nvim_input(M.firstc)
		M.exit_autocmd = vim.api.nvim_create_autocmd({ "BufLeave", "BufHidden" }, { buffer = M.buf, callback = M.exit })
	end)
end

function M.exe(firstc, cmd)
	M.mode = "exe"
	M.cmd = cmd
	vim.api.nvim_input(firstc)
	vim.api.nvim_input(ENTER)
end

function M.exit()
	if vim.api.nvim_win_is_valid(M.win) then
		vim.api.nvim_win_close(M.win, true)
		if M.opts.msgarea then
			vim.cmd("set cmdheight=" .. M.cmdheight)
		end
	end
	M.cmd = nil
	M.pos = 0
	M.firstc = nil
	M.prompt = nil
	M.win = -1
	M.buf = -1
	M.history = {}
	M.mode = "cmd"
end

function M.reemit(mode)
	vim.fn.setcmdline(M.cmd, M.pos + 1)
	M.mode = mode
end

function M.on_show(...)
	if M.mode == "edit" then
		M.render()
		M.reemit("cmd")
	elseif M.mode == "exe" then
		M.reemit("exit")
	elseif M.mode == "cmd" then
		local content
		content, M.pos, M.firstc, M.prompt, M.indent, _ = ...
		local cmd = ""
		for _, chunk in ipairs(content) do
			cmd = cmd .. chunk[2]
		end
		if M.cmd == cmd then
			return
		end
		M.cmd = cmd
		M.render()
	end
end

function M.on_pos(...)
	local pos, _ = ...
	M.pos = pos
	M.render()
end

function M.on_special_char(...)
	local c, shift, level = ...
	M.cmd = M.cmd:sub(1, M.pos) .. c .. M.cmd:sub(M.pos + 1)
	M.render()
end

function M.on_hide()
	-- You can't go to edit mode when in a prompt
	if M.prompt and M.prompt ~= "" then
		M.exit()
		return
	elseif M.mode == "edit" then
		return
	elseif M.mode == "cmd" or M.mode == "exit" then
		M.exit()
	else
		vim.notify("cmdline: unexpected 'cmdline_hide' event in mode: " .. M.mode, vim.log.levels.ERROR)
	end
end

function M.handler(event, ...)
	if event == "cmdline_show" then
		M.on_show(...)
	elseif event == "cmdline_pos" then
		M.on_pos(...)
	elseif event == "cmdline_hide" then
		M.on_hide()
	elseif event == "cmdline_special_char" then
		M.on_special_char(...)
	else
		-- ignore: (cmdline_block_show, cmdline_block_append and cmdline_block_hide)cmd
		return
	end
end

function M.attach()
	vim.ui_attach(M.namespace, { ext_cmdline = true }, function(event, ...)
		if event:match("cmd") ~= nil then
			M.handler(event, ...)
			return true
		else
			return false
		end
	end)
end

function M.disable()
	vim.keymap.del("c", "<esc>", { buffer = M.buf })
	vim.keymap.del("c", "<c-c>", { buffer = M.buf })
	vim.ui_detach(M.namespace)
	M.attached = false
end

function M.setup()
	M.namespace = vim.api.nvim_create_namespace("cmdline")
	vim.keymap.set("c", "<esc>", M.enter_edit, { desc = "Enter cmdline edit mode" })
	vim.keymap.set("c", "<c-c>", M.enter_edit, { desc = "Enter cmdline edit mode" })
	M.attach()
	M.attached = true
end

function M.toggle()
	if M.attached then
		M.disable()
	else
		M.attach()
	end
end

return M
