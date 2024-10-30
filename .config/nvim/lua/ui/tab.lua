local M = { ns = nil, win = -1, buf = -1 }

function M.init_buf()
	if vim.api.nvim_buf_is_loaded(M.buf) then
		return
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].modifiable = false
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].buflisted = false
	vim.bo[buf].undolevels = -1
	vim.api.nvim_buf_set_name(buf, "tabline")
	M.buf = buf
end

function M.init_win()
	if vim.api.nvim_win_is_valid(M.win) then
		return
	end
	local config = {
		relative = "editor",
		height = 1,
		width = vim.o.columns,
		row = vim.o.lines,
		col = 0,
		style = "minimal",
		-- border = "single",
		focusable = false,
		zindex = 200,
	}
	local win = vim.api.nvim_open_win(M.buf, false, config)
	vim.wo[win].winfixbuf = true
	M.win = win
end

function M.format_buf(buffers, curbuf)
	local curbuf_start
	local curbuf_end
	local buf_line = ""
	local stop = false
	for _, buf in ipairs(buffers) do
		local buf_name = buf["name"]
		if buf_name ~= "health://" then
			buf_name = vim.fn.fnamemodify(buf["name"], ":t")
		end
		if #buf_line + #buf_name > 100 then
			if stop then
				buf_line = buf_line .. ".."
				break
			else
				buf_line = ".."
			end
		end
		if buf["buffer"] == curbuf then
			curbuf_start = #buf_line
			curbuf_end = #buf_line + #buf_name + 2
			stop = true
		end
		buf_line = buf_line .. " " .. buf_name .. " "
	end
	return buf_line, curbuf_start, curbuf_end
end

function M.format_tab(tabs, curtab)
	local curtab_start
	local curtab_end
	local tab_line = ""
	for _, tab in ipairs(tabs) do
		if tab["tab"] == curtab then
			curtab_start = #tab_line
			curtab_end = #tab_line + #tostring(tab["tab"]) + 2
		end
		tab_line = tab_line .. " " .. tostring(tab["tab"]) .. " "
	end
	return tab_line, curtab_start, curtab_end
end

function M.render_tabline(curtab, tabs, curbuf, buffers)
	local b, b_hl_start, b_hl_end = M.format_buf(buffers, curbuf)
	local t, t_hl_start, t_hl_end = M.format_tab(tabs, curtab)
	local sep = string.rep(" ", vim.o.columns - string.len(b) - string.len(t))
	local tabline = b .. sep .. t
	vim.api.nvim_buf_set_lines(M.buf, 0, 1, false, { tabline })
	vim.highlight.range(M.buf, M.ns, "TabLine", { 0, 0 }, { 0, vim.o.columns })
	vim.highlight.range(M.buf, M.ns, "TabLineSel", { 0, b_hl_start }, { 0, b_hl_end })
	vim.highlight.range(M.buf, M.ns, "TabLineSel", { 0, t_hl_start + #b + #sep }, { 0, t_hl_end + #b + #sep })
end

function M.on_update(...)
	if vim.fn.mode() == "c" then
		return
	end
	local curtab, tabs, curbuf, buffers = ...
	if not vim.tbl_contains(vim.api.nvim_tabpage_list_wins(curtab), M.win, {}) then
		if vim.api.nvim_win_is_valid(M.win) then
			vim.api.nvim_win_close(M.win, true)
		end
		if vim.api.nvim_buf_is_loaded(M.buf) then
			vim.api.nvim_buf_delete(M.buf, {})
		end
		M.win = -1
		M.buf = -1
	end
	M.init_buf()
	M.init_win()
	vim.bo[M.buf].modifiable = true
	M.render_tabline(curtab, tabs, curbuf, buffers)
	vim.bo[M.buf].modifiable = false
end

function M.handler(event, ...)
	if event == "tabline_update" then
		M.on_update(...)
	else
		return
	end
end

function M.disable()
	vim.api.nvim_win_close(M.win, true)
	M.win = -1
	M.buf = -1
end

function M.setup()
	M.ns = vim.api.nvim_create_namespace("tabline")
	if vim.o.cmdheight == 0 then
		vim.o.cmdheight = 1
	end
end

return M
