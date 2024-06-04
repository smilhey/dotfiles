local M = { scrollbars = {}, ns = nil }

function M.bwin_get_config(win)
	local win_config = vim.api.nvim_win_get_config(win)
	local bwin_config = {
		relative = "win",
		win = win,
		height = win_config.height - 1,
		width = 1,
		row = 0,
		col = win_config.width - 1,
		style = "minimal",
		-- border = "single",
		focusable = false,
		zindex = 40,
	}
	return bwin_config
end

function M.bwin_open(win, bbuf)
	local bwin_config = M.bwin_get_config(win)
	local bwin = vim.api.nvim_open_win(bbuf, false, bwin_config)
	return bwin
end

function M.bbuf_create()
	local bbuf = vim.api.nvim_create_buf(false, true)
	vim.bo[bbuf].bufhidden = "wipe"
	vim.bo[bbuf].buftype = "nofile"
	local fill = {}
	for _ = 1, vim.o.lines do
		table.insert(fill, " ")
	end
	vim.api.nvim_buf_set_lines(bbuf, 0, -1, false, fill)
	vim.bo[bbuf].modifiable = false
	vim.bo[bbuf].buftype = "nofile"
	vim.bo[bbuf].bufhidden = "wipe"
	vim.bo[bbuf].swapfile = false
	vim.bo[bbuf].buflisted = false
	vim.bo[bbuf].undolevels = -1
	return bbuf
end

function M.sb_render(ns, win, bwin)
	local buf, bbuf = vim.api.nvim_win_get_buf(win), vim.api.nvim_win_get_buf(bwin)
	local bwin_height = vim.api.nvim_win_get_height(bwin)
	local top_line = vim.fn.line("w0", win)
	local total_lines = vim.api.nvim_buf_line_count(buf)
	local thumb_pos = math.floor(top_line / total_lines * bwin_height)
	local thumb_size = math.ceil(bwin_height / total_lines * bwin_height)
	thumb_pos = math.max(1, math.min(thumb_pos, bwin_height - thumb_size + 1))
	vim.api.nvim_buf_clear_namespace(bbuf, ns, 0, -1)
	for i = 1, bwin_height do
		-- local hl_group = (i >= thumb_pos and i < thumb_pos + thumb_size) and "SbarThumb" or "Sbar"
		local hl_group = (i >= thumb_pos and i < thumb_pos + thumb_size) and "PmenuThumb" or "PmenuSbar"
		vim.api.nvim_buf_set_extmark(bbuf, ns, i - 1, 0, {
			virt_text = { { " ", hl_group } },
			virt_text_pos = "overlay",
		})
	end
end

function M.sb_show(win)
	local buf = vim.api.nvim_win_get_buf(win)
	if vim.bo[buf].buftype == "help" then
		return true
	end
	if vim.bo[buf].buftype == "prompt" then
		return false
	end
	if vim.bo[buf].buftype == "nofile" then
		return false
	end
	if vim.fn.win_gettype(win) ~= "" then
		return false
	end
	return true
end

function M.sb_del(bwin)
	if vim.api.nvim_win_is_valid(bwin) then
		vim.api.nvim_win_close(bwin, true)
	end
end

function M.sb_create(win)
	local bbuf = M.bbuf_create()
	local bwin = M.bwin_open(win, bbuf)
	return bwin
end

function M.sb_update(ns, win, bwin)
	if not vim.api.nvim_win_is_valid(bwin) or not vim.api.nvim_win_is_valid(win) then
		M.sb_del(bwin)
		return
	end
	if not M.sb_show(win) then
		M.sb_del(bwin)
		return
	end
	local bwin_config = M.bwin_get_config(win)
	vim.api.nvim_win_set_config(bwin, bwin_config)
	M.sb_render(ns, win, bwin)
end

function M.update()
	local wins = vim.tbl_filter(function(win)
		return M.sb_show(win) and not M.scrollbars[win] and not vim.tbl_contains(M.scrollbars, win)
	end, vim.api.nvim_list_wins())
	for _, win in ipairs(wins) do
		M.scrollbars[win] = M.sb_create(win)
	end
	for win, bwin in pairs(M.scrollbars) do
		M.sb_update(M.ns, win, bwin)
		local valid = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_is_valid(bwin)
		if not valid then
			M.scrollbars[win] = nil
		end
	end
end

function M.clear()
	for win, bwin in pairs(M.scrollbars) do
		M.sb_del(bwin)
		M.scrollbars[win] = nil
	end
end

function M.disable()
	M.clear()
	vim.api.nvim_del_augroup_by_id(M.augroup)
	M.enabled = false
end

function M.setup()
	M.ns = vim.api.nvim_create_namespace("scrollbar")
	M.augroup = vim.api.nvim_create_augroup("scrollbar", { clear = true })
	vim.api.nvim_create_autocmd({ "WinScrolled" }, {
		group = M.augroup,
		callback = vim.schedule_wrap(M.update),
	})
	M.enabled = true
end

function M.toggle()
	if M.enabled then
		M.disable()
	else
		M.setup()
	end
end

return M