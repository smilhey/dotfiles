local format = require("repl.format")
local M = {}

function M.get_repl(chan)
	local chan_info = vim.api.nvim_get_chan_info(chan)
	local argv = chan_info.argv
	for _, str in ipairs(argv) do
		local cmd = vim.fs.basename(str)
		if vim.tbl_contains(format.supported, cmd) then
			return cmd
		end
	end
	return nil
end

function M.send_selection(chan, selection, buf, mark)
	local repl = M.get_repl(chan)
	repl = repl and repl or "default"
	local data = format.input[repl](selection)
	data = (buf and mark) and format.pad(data, repl, buf, mark) or data
	vim.api.nvim_chan_send(chan, data)
end

function M.get_range_marks(buf, ns, start_row, start_col, end_row, end_col)
	local marks_info = vim.api.nvim_buf_get_extmarks(
		buf,
		ns,
		{ start_row, start_col },
		{ end_row, end_col },
		{ overlap = true, details = true }
	)
	if vim.tbl_isempty(marks_info) then
		return {}
	end
	-- case where one begins after another ends mark_1|mark_2
	-- if the cursor is on the 2nd 'm' you'll get both marks
	local end_row_1 = marks_info[1][4].end_row
	local end_col_1 = marks_info[1][4].end_col
	if end_col_1 == start_col and end_row_1 == start_row then
		table.remove(marks_info, 1)
	end
	return vim.tbl_map(function(mark_info)
		return mark_info[1]
	end, marks_info)
end

function M.get_cursor_mark(ns)
	local buf = vim.api.nvim_get_current_buf()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local mark_list = M.get_range_marks(buf, ns, row - 1, col, row - 1, col)
	if #mark_list == 1 then
		return mark_list[1]
	elseif #mark_list > 1 then
		vim.notify("Overlapping cells", vim.log.levels.ERROR)
	end
end

return M
