local BS = vim.api.nvim_replace_termcodes("<bs>", true, true, true)
local M = {
	attached = false,
	buf = -1,
	win = -1,
	cmd = nil,
	pos = 0,
	firtc = nil,
	prompt = nil,
	size = 0,
	cmdheight = nil,
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
	-- win_opts = {
	-- 	relative = "editor",
	-- 	zindex = 200,
	-- 	row = vim.o.lines,
	-- 	col = 0,
	-- 	style = "minimal",
	-- 	width = vim.o.columns,
	-- 	height = 1,
	-- },
	opts = { msgarea = false },
}

function M.exit()
	if not vim.api.nvim_win_is_valid(M.win) then
		return
	end
	vim.api.nvim_win_close(M.win, true)
	M.cmd = nil
	M.pos = 0
	M.firstc = nil
	M.prompt = nil
	M.win = -1
	M.buf = -1
	vim.cmd("set cmdheight=" .. M.cmdheight)
end

function M.init_buf()
	if vim.api.nvim_buf_is_loaded(M.buf) then
		return
	end
	M.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[M.buf].filetype = "vim"
	vim.bo[M.buf].buftype = "nofile"
	vim.bo[M.buf].bufhidden = "wipe"
	vim.api.nvim_buf_set_name(M.buf, "cmdline")
	vim.api.nvim_create_autocmd({ "BufHidden", "BufLeave" }, { buffer = M.buf, callback = M.exit })
end

function M.resize_win()
	local width = math.max(M.size, M.win_opts.width)
	local col = math.ceil((vim.o.columns - width) / 2)
	if width ~= M.win_opts.width or col ~= M.win_opts.col then
		vim.api.nvim_win_set_config(M.win, { relative = "editor", width = width, col = col, row = M.win_opts.row })
	end
end

function M.init_win()
	if vim.api.nvim_win_is_valid(M.win) then
		M.resize_win()
		return
	end
	if M.opts.msgarea then
		M.cmdheight = vim.o.cmdheight
		if M.cmdheight == 0 then
			vim.cmd("set cmdheight=1")
		end
	end
	M.win = vim.api.nvim_open_win(M.buf, false, M.win_opts)
	M.resize_win()
	vim.api.nvim_win_set_hl_ns(M.win, M.namespace)
	vim.wo[M.win].winfixbuf = true
	vim.wo[M.win].virtualedit = "all,onemore"
	vim.api.nvim__redraw({ cursor = true, flush = true })
end

function M.render()
	M.init_buf()
	local cmd_prompt = (" "):rep(M.indent) .. M.firstc .. M.prompt
	vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, { M.cmd })
	if not vim.api.nvim_win_is_valid(M.win) then
		vim.api.nvim_buf_set_extmark(
			M.buf,
			M.namespace,
			0,
			0,
			{ right_gravity = false, virt_text_pos = "inline", virt_text = { { cmd_prompt, "Normal" } } }
		)
	end
	M.init_win()
	vim.api.nvim_win_set_cursor(M.win, { 1, M.pos })
	vim.api.nvim__redraw({ flush = true, cursor = true, win = M.win })
end

function M.on_cmdline_show(...)
	local content
	content, M.pos, M.firstc, M.prompt, M.indent, _ = ...
	M.pos = M.pos
	local cmd = ""
	for _, chunk in ipairs(content) do
		cmd = cmd .. chunk[2]
	end
	if M.cmd == cmd then
		return
	end
	M.cmd = cmd
	-- the 1 is for the cursor
	M.size = #M.prompt + #M.firstc + #M.cmd + 1
	M.render()
end

function M.on_cmdline_pos(...)
	local pos, _ = ...
	M.pos = pos
	M.render()
end

function M.on_cmdline_hide()
	M.exit()
end

function M.handler(event, ...)
	if event == "cmdline_show" then
		M.on_cmdline_show(...)
	elseif event == "cmdline_pos" then
		M.on_cmdline_pos(...)
	elseif event == "cmdline_hide" then
		M.on_cmdline_hide()
	else
		-- ignore (cmdline_special_char, cmdline_block_show, cmdline_block_append and cmdline_block_hide)
		return
	end
end

function M.attach()
	vim.ui_attach(M.namespace, { ext_cmdline = true }, function(event, ...)
		M.handler(event, ...)
		if event:match("cmd") ~= nil then
			return true
		end
		return false
	end)
end

function M.disable()
	vim.ui_detach(M.namespace)
	M.attached = false
end

function M.setup()
	M.namespace = vim.api.nvim_create_namespace("cmdline")
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
