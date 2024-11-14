local output = require("repl.output")
local utils = require("repl.utils")

local M =
	{ ns = vim.api.nvim_create_namespace("cells"), augroup = vim.api.nvim_create_augroup("cells", {}), cur_mark = -1 }

function M.enable_on_cursor(buf, hl, float, virt)
	if not hl and not float then
		return
	end
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		group = M.augroup,
		buffer = buf,
		desc = "highlight mark under cursor and show output in float",
		callback = function()
			local mark = M.get_cursor()
			if mark == M.cur_mark then
				return
			end
			if mark then
				if float then
					output.display_float(buf, mark)
				end
				if hl then
					M.set_hl(buf, M.cur_mark)
					M.set_hl(buf, mark, "TabLineSel")
				end
				M.cur_mark = mark
			else
				if hl then
					M.set_hl(buf, M.cur_mark)
				end
				if float then
					output.clear_float()
					if virt then
						M.display_virt(buf, M.cur_mark)
					else
						vim.api.nvim_buf_del_extmark(buf, output.ns, M.cur_mark)
					end
				end
				M.cur_mark = -1
			end
		end,
	})
end

function M.set_hl(buf, mark, hl_group)
	local mark_info = vim.api.nvim_buf_get_extmark_by_id(buf, M.ns, mark, { details = true })
	if vim.tbl_isempty(mark_info) then
		return
	end
	vim.api.nvim_buf_set_extmark(buf, M.ns, mark_info[1], mark_info[2], {
		id = mark,
		end_row = mark_info[3].end_row,
		end_col = mark_info[3].end_col,
		hl_group = hl_group,
	})
end

function M.disable_hl(buf)
	local autocmd = vim.api.nvim_get_autocmds({ group = M.augroup, buffer = buf })[1].id
	if autocmd then
		vim.api.nvim_del_autocmd(autocmd)
	end
end

function M.set(buf, start_row, start_col, end_row, end_col)
	return vim.api.nvim_buf_set_extmark(buf, M.ns, start_row, start_col, { end_row = end_row, end_col = end_col })
end

function M.del_all(buf)
	output.clear_float()
	vim.api.nvim_buf_clear_namespace(buf, output.ns, 0, -1)
	vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
end

function M.del(buf, mark)
	output.clear_float()
	vim.api.nvim_buf_del_extmark(buf, output.ns, mark)
	vim.api.nvim_buf_del_extmark(buf, M.ns, mark)
end

function M.send(chan, buf, mark)
	local mark_info = vim.api.nvim_buf_get_extmark_by_id(buf, M.ns, mark, { details = true })
	if vim.tbl_isempty(mark_info) then
		output.clear_queue(chan, buf)
		vim.notify("Cell was cleared before being processed", vim.log.levels.WARN)
		return
	end
	local start_row, start_col, end_row, end_col =
		mark_info[1], mark_info[2], mark_info[3].end_row, mark_info[3].end_col
	local selection = vim.api.nvim_buf_get_text(buf, start_row, start_col, end_row, end_col, {})
	if output.enabled[chan] then
		local queued = output.add_to_queue(chan, buf, mark)
		if not queued then
			M.del(buf, mark)
			return
		end
		if vim.deep_equal(output.queue[chan][1], { buf, mark }) then
			utils.send_selection(chan, selection, buf, mark)
		else
			vim.defer_fn(function()
				M.send(chan, buf, mark, true)
			end, 200)
		end
	else
		utils.send_selection(chan, selection)
	end
	local cur_mark = M.get_cursor()
	if cur_mark and cur_mark == mark then
		M.set_hl(buf, mark, "TabLineSel")
		M.cur_mark = cur_mark
	end
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

function M.get_cursor()
	local buf = vim.api.nvim_get_current_buf()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local marks = M.get(buf, row - 1, col, row - 1, col)
	if #marks == 1 then
		return marks[1]
	elseif #marks > 1 then
		vim.notify("Overlapping marks", vim.log.levels.ERROR)
	end
end

return M
