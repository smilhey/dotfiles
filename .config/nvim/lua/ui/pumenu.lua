local cmdwin = require("ui.cmdwin")

local M = {
	attached = false,
	buf = -1,
	win = -1,
	win_opts = {
		zindex = 250,
		relative = "editor",
		width = 1,
		height = 1,
		row = 1,
		col = 1,
		focusable = false,
		-- border = "single",
		style = "minimal",
	},
	opts = {
		max_items = 10,
		type = "float",
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
	local height = math.min(#M.items, M.opts.max_items, math.max(vim.o.lines - M.row - 3, M.row))
	M.height = height
	local width = M.width
	local row = M.row
	local col = M.col
	if cmdwin.win == -1 then
		if row == 0 then
			row = vim.o.lines - vim.o.cmdheight - height
		elseif height > vim.o.lines - row - 3 then
			row = row - height
		else
			row = row + 1
		end
		if M.row ~= 0 and M.col ~= 0 then
			col = col - 1
		end
	end
	if M.opts.type == "float" and cmdwin.win ~= -1 then
		local config = vim.api.nvim_win_get_config(cmdwin.win)
		width = config.width
		row = config.row + 3
		col = config.col + 1
	end
	M.pum_row = row
	M.pum_col = col
	vim.api.nvim_win_set_config(M.win, { relative = "editor", width = width, height = height, row = row, col = col })
end

function M.init_window()
	if not vim.api.nvim_win_is_valid(M.win) then
		M.win = vim.api.nvim_open_win(M.buf, false, M.win_opts)
		vim.wo[M.win].wrap = false
	end
	vim.api.nvim_win_set_hl_ns(M.win, M.ns)
	M.update_window()
end

function M.render_scrollbar()
	if #M.items <= M.height then
		return
	end
	local first_line = vim.fn.line("w0", M.win)
	local last_line = vim.fn.line("w$", M.win)
	local thumb_size = math.ceil(M.height * M.height / #M.items)
	local thumb_pos = math.floor(first_line / #M.items * M.height)
	thumb_pos = math.min(thumb_pos + first_line, last_line - thumb_size + 1)
	for i = first_line, last_line do
		local is_thumb = i >= thumb_pos and i < thumb_pos + thumb_size
		local hl_group = is_thumb and "PmenuThumb" or "PmenuSbar"
		vim.api.nvim_buf_set_extmark(
			M.buf,
			M.ns,
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
		if cmdwin.win ~= -1 then
			vim.api.nvim_buf_set_extmark(M.buf, M.ns, M.selected, 0, { line_hl_group = "PmenuSel" })
		else
			vim.api.nvim_buf_set_extmark(
				M.buf,
				M.ns,
				M.selected,
				0,
				{ end_col = M.kind_col_start, strict = false, hl_group = "PmenuSel" }
			)
			local has_kind = M.string_items[M.selected + 1]:sub(M.kind_col_start + 1, M.kind_col_start + 1) ~= " "
			local has_menu = M.string_items[M.selected + 1]:sub(M.menu_col_start + 1, M.menu_col_start + 1) ~= " "
			local hl_kind_sel = has_kind and "PmenuKindSel" or "PmenuSel"
			local hl_menu_sel = has_menu and "PmenuExtraSel" or "PmenuSel"

			vim.api.nvim_buf_set_extmark(
				M.buf,
				M.ns,
				M.selected,
				M.kind_col_start,
				{ end_col = M.kind_col_end, hl_group = hl_kind_sel }
			)
			vim.api.nvim_buf_set_extmark(
				M.buf,
				M.ns,
				M.selected,
				M.menu_col_start,
				{ end_col = M.menu_col_end, hl_group = hl_menu_sel }
			)
		end
		vim.api.nvim_win_set_cursor(M.win, { M.selected + 1, 0 })
	end
	M.render_scrollbar()
end

function M.exit()
	vim.api.nvim_win_close(M.win, true)
	M.win = -1
	M.buf = -1
end

function M.format(items)
	local word_len, kind_len, menu_len = 0, 0, 0
	local string_items = {}
	for _, item in ipairs(items) do
		if M.row == 0 or M.col ~= 0 then
			item[1] = " " .. item[1]
		end
		word_len = math.max(word_len, #item[1])
		kind_len = math.max(kind_len, #item[2])
		menu_len = math.max(menu_len, #item[3])
	end
	local has_kind = kind_len == 0 and 0 or 1
	local has_menu = menu_len == 0 and 0 or 1
	for _, item in ipairs(items) do
		item[1] = item[1]
			.. string.rep(" ", word_len - #item[1])
			.. (" "):rep(has_kind + has_menu - has_kind * has_menu)
			.. (" "):rep(3 * (1 - has_kind) * (1 - has_menu))
		item[2] = item[2]
			.. string.rep(" ", kind_len - #item[2])
			.. (" "):rep(has_menu * has_kind)
			.. (" "):rep(3 * (1 - has_menu) * has_kind)
		item[3] = item[3] .. string.rep(" ", menu_len - #item[3]) .. (" "):rep(3 * has_menu)
		local match = item[1] .. item[2] .. item[3]
		string_items[#string_items + 1] = match
	end
	local kind_col_start, kind_col_end = #items[1][1], #items[1][1] + #items[1][2]
	local menu_col_start, menu_col_end = #items[1][1] + #items[1][2], #items[1][1] + #items[1][2] + #items[1][3]
	M.width = math.min(unpack(vim.tbl_map(function(str)
		return vim.api.nvim_strwidth(str)
	end, string_items)))
	-- M.width = word_len + has_kind + kind_len + has_menu + menu_len + 3
	return string_items, kind_col_start, kind_col_end, menu_col_start, menu_col_end
end

function M.on_show(...)
	M.items, M.selected, M.row, M.col, _ = ...
	M.string_items, M.kind_col_start, M.kind_col_end, M.menu_col_start, M.menu_col_end = M.format(M.items)
	M.render()
end

function M.on_select(...)
	M.selected = ...
	M.render()
end

function M.on_hide()
	M.exit()
end

function M.handler(event, ...)
	if event == "popupmenu_show" then
		M.on_show(...)
	elseif event == "popupmenu_select" then
		M.on_select(...)
	elseif event == "popupmenu_hide" then
		M.on_hide()
	end
end

function M.attach()
	vim.ui_attach(M.ns, { ext_popupmenu = true }, function(event, ...)
		if event:match("pop") ~= nil then
			M.handler(event, ...)
		end
	end)
end

function M.disable()
	vim.fn.pum_getpos = M.old_pum_getpos
	vim.ui_detach(M.ns)
	M.attached = false
end

function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", M.opts, opts)
	M.ns = vim.api.nvim_create_namespace("pmenu")
	vim.api.nvim_set_hl(M.ns, "Normal", { link = "Pmenu" })
	M.attach()
	M.attached = true
	M.old_pum_getpos = vim.fn.pum_getpos
	vim.fn.pum_getpos = function()
		if M.win == -1 or not vim.api.nvim_win_is_valid(M.win) then
			return {}
		else
			return {
				height = M.height,
				width = M.width,
				row = M.pum_row,
				col = M.pum_col,
				size = #M.items,
				scrollbar = #M.items > M.height,
			}
		end
	end
end

function M.toggle()
	if M.attached then
		M.disable()
	else
		M.attach()
	end
end

return M