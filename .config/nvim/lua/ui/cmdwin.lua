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
		width = math.ceil(vim.o.columns / 3),
		row = math.floor(vim.o.lines * 0.2),
		col = math.floor(vim.o.columns / 3),
		height = 1,
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
	vim.keymap.set("n", "<cr>", M.exe, { buffer = M.buf, noremap = true })
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
		vim.wo[M.win].virtualedit = "onemore"
		vim.api.nvim_win_set_hl_ns(M.win, M.ns)
	end
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
end

function M.render()
	if not M.firstc or not M.prompt then
		return
	end
	M.init_buf()
	if not vim.api.nvim_win_is_valid(M.win) then
		M.init_win()
		if M.prompt and M.prompt ~= "" then
			vim.api.nvim_buf_set_lines(M.buf, 0, 0, false, { M.cmd })
			vim.api.nvim_buf_set_extmark(M.buf, M.ns, 0, 0, {
				virt_text = { { M.prompt, "MsgArea" } },
				virt_text_pos = "inline",
				right_gravity = false,
			})
			vim.api.nvim_win_set_cursor(M.win, { 1, M.pos })
		elseif M.firstc and M.firstc ~= "" then
			M.set_history()
			vim.wo[M.win].statuscolumn = "%#MsgArea#" .. M.firstc
			vim.api.nvim_buf_set_lines(M.buf, -1, -1, false, { (" "):rep(M.indent) .. M.cmd })
			vim.api.nvim_win_set_cursor(M.win, { vim.fn.line("$", M.win), M.indent + M.pos })
		end
	else
		vim.api.nvim_buf_set_lines(
			M.buf,
			vim.fn.line(".", M.win) - 1,
			vim.fn.line(".", M.win),
			false,
			{ (" "):rep(M.indent) .. M.cmd }
		)
		vim.api.nvim_win_set_cursor(M.win, { vim.fn.line(".", M.win), M.indent + M.pos })
	end
	M.resize_win()
	vim.api.nvim__redraw({ flush = true, cursor = true, win = M.win })
end

function M.enter_edit()
	M.intercept = true
	vim.api.nvim_feedkeys(ESC, "nt", false)
	M.pos = M.pos > 0 and M.pos - 1 or M.pos
	local line = vim.fn.line(".", M.win)
	vim.api.nvim_set_current_win(M.win)
	vim.schedule(function()
		if vim.api.nvim_win_is_valid(M.win) then
			vim.api.nvim_win_set_cursor(M.win, { line, M.pos })
		end
	end)
end

function M.exit_edit()
	local curpos = vim.api.nvim_win_get_cursor(M.win)
	M.pos = curpos[2]
	M.cmd = vim.api.nvim_get_current_line()
	vim.api.nvim_del_autocmd(M.exit_autocmd)
	vim.api.nvim_set_current_win(M.curr_win)
	M.exit_autocmd = vim.api.nvim_create_autocmd({ "BufLeave", "BufHidden" }, { buffer = M.buf, callback = M.exit })
	vim.api.nvim_input(M.firstc)
end

function M.exe()
	M.exit_edit()
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
	M.intercept = false
end

function M.reemit()
	vim.fn.setcmdline(M.cmd, M.pos + 1)
	M.render()
	M.intercept = false
end

function M.on_show(...)
	if M.intercept then
		M.reemit()
		return
	end
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
	if (M.prompt and M.prompt ~= "") or not M.intercept then
		M.exit()
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

function M.disable()
	vim.keymap.del("c", "<esc>")
	vim.keymap.del("c", "<c-c>")
	M.exit()
end

function M.setup()
	M.augroup = vim.api.nvim_create_augroup("cmdline-resize", { clear = true })
	M.ns = vim.api.nvim_create_namespace("cmdline")
	vim.api.nvim_set_hl(M.ns, "NormalFloat", { link = "MsgArea" })
	vim.api.nvim_set_hl(M.ns, "Search", { link = "MsgArea" })
	vim.api.nvim_set_hl(M.ns, "CurSearch", { link = "MsgArea" })
	vim.api.nvim_set_hl(M.ns, "Substitute", { link = "MsgArea" })
	vim.keymap.set("c", "<esc>", M.enter_edit, { desc = "Enter cmdline edit mode" })
	vim.keymap.set("c", "<c-c>", M.enter_edit, { desc = "Enter cmdline edit mode" })
	vim.api.nvim_create_autocmd("VimResized", {
		desc = "ed-cmd keep its relative pos",
		group = M.augroup,
		callback = function()
			M.win_opts = {
				relative = "editor",
				width = math.ceil(vim.o.columns / 3),
				row = math.floor(vim.o.lines * 0.2),
				col = math.floor(vim.o.columns / 3),
				height = 1,
				style = "minimal",
				border = "single",
				zindex = 200,
			}
			if vim.api.nvim_win_is_valid(M.win) then
				vim.api.nvim_win_set_config(M.win, M.win_opts)
				M.render()
			end
		end,
	})
end

return M
