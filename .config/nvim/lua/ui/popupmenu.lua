local cmdwin = require("ui.cmdwin")
local cmdline_position = { cmdwin.win_opts.row, cmdwin.win_opts.col }
local M = {
	attached = false,
	buf = -1,
	win = -1,
	col_offset = 0,
	row_offset = 0,
	opts = {
		max_items = 20,
		resize = "cmdline",
		win_opts = {
			relative = "editor",
			width = 1,
			height = 1,
			row = 1,
			col = 1,
			focusable = false,
			border = "single",
			style = "minimal",
		},
	},
}

function M.init_buffer()
	if vim.api.nvim_buf_is_valid(M.buf) then
		return
	end
	M.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[M.buf].bufhidden = "wipe"
	vim.api.nvim_buf_set_name(M.buf, "popupmenu")
end

function M.update_window()
	local width = M.opts.win_opts.width
	local height = math.min(#M.items, M.opts.max_items)
	local row = M.row
	local col = M.col
	if M.opts.resize == "dynamic" or cmdwin.win == -1 then
		width = math.max(unpack(vim.tbl_map(function(string)
			return #string
		end, M.string_items)))
	end
	if M.opts.resize == "cmdline" and cmdwin.win ~= -1 then
		local config = vim.api.nvim_win_get_config(cmdwin.win)
		width = config.width
		row = config.row
		col = config.col
	end
	row = row >= vim.o.lines / 2 and row - height - 2 or row + 3
	vim.api.nvim_win_set_config(M.win, { relative = "editor", width = width, height = height, row = row, col = col })
end

function M.init_window()
	if not vim.api.nvim_win_is_valid(M.win) then
		M.win = vim.api.nvim_open_win(M.buf, false, M.opts.win_opts)
		vim.wo[M.win].wrap = false
	end
	M.update_window()
end

function M.render_scrollbar()
	if #M.items <= M.opts.max_items then
		return
	end
	local first_line = vim.fn.line("w0", M.win)
	local last_line = vim.fn.line("w$", M.win)
	local thumb_size = math.ceil(M.opts.max_items * M.opts.max_items / #M.items)
	local thumb_pos = math.floor(first_line / #M.items * M.opts.max_items)
	thumb_pos = math.min(thumb_pos + first_line, last_line - thumb_size + 1)
	for i = first_line, last_line do
		local is_thumb = i >= thumb_pos and i < thumb_pos + thumb_size
		local hl_group = is_thumb and "PmenuThumb" or "PmenuSbar"
		vim.api.nvim_buf_set_extmark(
			M.buf,
			M.namespace,
			i - 1,
			0,
			{ virt_text_pos = "right_align", virt_text = { { " ", hl_group } } }
		)
	end
end

function M.render()
	M.init_buffer()
	M.init_window()
	vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, M.string_items)
	if M.selected ~= -1 then
		vim.api.nvim_buf_set_extmark(M.buf, M.namespace, M.selected, 0, { hl_eol = true, line_hl_group = "PmenuSel" })
		vim.api.nvim_win_set_cursor(M.win, { M.selected + 1, 0 })
	end
	M.render_scrollbar()
end

function M.exit()
	vim.api.nvim_win_close(M.win, true)
	M.win = -1
	M.buf = -1
end

function M.on_popupmenu_show(...)
	M.items, M.selected, M.row, M.col, _ = ...
	M.col = M.row == 0 and M.col + M.col_offset or M.col
	M.row = M.row == 0 and M.row_offset or M.row
	M.string_items = vim.tbl_map(function(item)
		return table.concat(item, " ")
	end, M.items)
	M.render()
end

function M.on_popupmenu_select(...)
	M.selected = ...
	M.render()
end

function M.on_popupmenu_hide()
	M.exit()
end

function M.handler(event, ...)
	if event == "popupmenu_show" then
		M.on_popupmenu_show(...)
	elseif event == "popupmenu_select" then
		M.on_popupmenu_select(...)
	elseif event == "popupmenu_hide" then
		M.on_popupmenu_hide()
	end
end

function M.attach()
	vim.ui_attach(M.namespace, { ext_popupmenu = true }, function(event, ...)
		M.handler(event, ...)
		if event:match("pop") ~= nil then
			return true
		end
		return false
	end)
end

function M.disable()
	vim.ui_detach(M.namespace)
	M.attached = false
end
function M.setup(opts)
	M.row_offset = cmdline_position[1]
	M.col_offset = cmdline_position[2]
	M.opts = vim.tbl_deep_extend("force", M.opts, opts)
	M.namespace = vim.api.nvim_create_namespace("popupmenu")
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
