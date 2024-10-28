local output = require("repl.output")
local format = require("repl.format")
local utils = require("repl.utils")
local M = { ns = vim.api.nvim_create_namespace("cells") }

function M.set(buf, start_row, start_col, end_row, end_col)
	return vim.api.nvim_buf_set_extmark(
		buf,
		M.ns,
		start_row,
		start_col,
		{ end_row = end_row, end_col = end_col, hl_group = "Visual" }
	)
end

function M.del(buf, mark)
	output.clear_float()
	output.clear_virt(buf, mark)
	vim.api.nvim_buf_del_extmark(buf, M.ns, mark)
end

function M.send(chan, buf, mark)
	local mark_info = vim.api.nvim_buf_get_extmark_by_id(buf, M.ns, mark, { details = true })
	if vim.tbl_isempty(mark_info) then
		vim.notify("Cell cleared", vim.log.levels.INFO)
		return
	end
	local start_row, start_col, end_row, end_col =
		mark_info[1], mark_info[2], mark_info[3].end_row, mark_info[3].end_col
	local selection = vim.api.nvim_buf_get_text(buf, start_row, start_col, end_row, end_col, {})
	local repl = utils.get_repl(chan)
	if output.enabled[chan] then
		output.add_to_queue(chan, buf, mark)
		if not vim.deep_equal(output.queue[chan][1], { buf, mark }) then
			vim.defer_fn(function()
				M.send(chan, buf, mark)
			end, 200)
			return
		end
		selection = format.pad(selection, repl, buf, mark)
	end

	utils.send_selection(chan, selection)
end

function M.get(buf, start_row, start_col, end_row, end_col)
	local marks_info = vim.api.nvim_buf_get_extmarks(
		buf,
		M.ns,
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
	local marks = vim.tbl_map(function(mark_info)
		return mark_info[1]
	end, marks_info)
	return marks
end

return M
