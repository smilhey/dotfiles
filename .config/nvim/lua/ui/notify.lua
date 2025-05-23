local messages = require("ui.messages")
local M = {
	win = -1,
	buf = -1,
	msg = nil,
	enabled = false,
	timeout = 4000,
}

M.hl_table = {
	"Debug", -- vim.log.levels.TRACE
	"Debug", -- vim.log.levels.DEBUG
	"Normal", -- vim.log.levels.INFO
	"WarningMsg", -- vim.log.levels.WARN
	"ErrorMsg", -- vim.log.levels.ERROR
	"Normal", -- vim.log.levels.OFF
}

function M.init_buf()
	if vim.api.nvim_buf_is_loaded(M.buf) then
		return
	end
	M.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[M.buf].bufhidden = "wipe"
end

function M.resize_win()
	local buf_lines = vim.api.nvim_buf_get_lines(M.buf, 0, -1, false)
	local height = math.min(#buf_lines, 4)
	local width = math.max(unpack(vim.tbl_map(function(line)
		return #line
	end, vim.list_slice(buf_lines, #buf_lines - height + 1, #buf_lines))))
	local col = vim.o.columns - width
	local row = vim.o.lines - height - 1 - vim.o.cmdheight
	vim.api.nvim_win_set_config(M.win, { relative = "editor", width = width, height = height, col = col, row = row })
end

function M.init_win()
	if not vim.api.nvim_win_is_valid(M.win) then
		M.win = vim.api.nvim_open_win(M.buf, false, {
			relative = "editor",
			row = 1,
			col = 1,
			width = 1,
			height = 1,
			focusable = false,
			style = "minimal",
			-- border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
			-- border = { "┏", "━", "━", " ", " ", " ", "┃", "┃" },
			-- border = "single",
			zindex = 60,
		})
	end
	-- vim.wo[M.win].winblend = 100
	vim.api.nvim_win_set_hl_ns(M.win, M.ns)
	M.resize_win()
end

function M.render(msg, log_level)
	local lines_count = vim.api.nvim_buf_line_count(M.buf)
	local lines = vim.split(msg, "\n")
	lines = vim.tbl_map(function(line)
		return vim.trim(line) .. " █"
	end, lines)
	local fill = vim.tbl_map(function(line)
		return (" "):rep(#line)
	end, lines)
	if vim.deep_equal(vim.api.nvim_buf_get_lines(M.buf, 0, -1, false), { "" }) then
		lines_count = 0
		vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, fill)
	else
		vim.api.nvim_buf_set_lines(M.buf, -1, -1, false, fill)
	end
	for i, line in ipairs(lines) do
		vim.api.nvim_buf_set_extmark(
			M.buf,
			M.ns,
			i - 1 + lines_count,
			0,
			{ virt_text_pos = "right_align", virt_text = { { line, M.hl_table[log_level + 1] } } }
		)
	end
end

function M.clear()
	if vim.api.nvim_win_is_valid(M.win) then
		vim.api.nvim_win_close(M.win, true)
	end
	M.win = -1
	M.buf = -1
	M.msg = nil
end

function M.notify(msg, log_level, opts)
	log_level = log_level and log_level or 3
	if M.msg and M.msg == msg then
		return
	elseif msg == "" or msg == nil then
		M.clear()
		return
	else
		M.timer:stop()
		M.timer:start(M.timeout, 0, function()
			M.timer:stop()
			vim.schedule(M.clear)
		end)
	end
	messages.add_to_history(msg, M.hl_table[log_level + 1])
	M.msg = msg
	M.init_buf()
	M.render(msg, log_level)
	M.init_win()
	vim.api.nvim_win_set_cursor(M.win, { vim.fn.line("$", M.win), 0 })
end

function M.setup()
	M.timer = vim.uv.new_timer()
	M.ns = vim.api.nvim_create_namespace("notif")
	vim.api.nvim_set_hl(M.ns, "NormalFloat", { link = "Normal" })
	M.old_notify = vim.notify
	vim.notify = M.notify
	M.enabled = true
end

function M.disable()
	vim.notify = M.old_notify
	M.clear()
	M.enabled = false
end

function M.toggle()
	if M.enabled then
		M.disable()
	else
		M.setup()
	end
end

return M
