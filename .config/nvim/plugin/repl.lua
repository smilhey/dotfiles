Repl = {}
local M = { attached_buffers = {} }
M.ns = vim.api.nvim_create_namespace("repl")

function M.is_term(buf)
	local chan_info_list = vim.api.nvim_list_chans()
	for _, chan_info in ipairs(chan_info_list) do
		if chan_info.buffer == buf then
			return true
		end
	end
	return false
end

function M.is_attached(buf)
	return M.attached_buffers[buf] ~= nil and vim.api.nvim_buf_is_valid(M.attached_buffers[buf].tbuf)
end

function M.attach(buf, tbuf, chan)
	M.attached_buffers[buf] = { tbuf = tbuf, chan = chan }
end

function M.selection_to_data(selection)
	return table.concat(selection, "\n") .. "\r"
end

function M.send_to_term(buf, data)
	local chan = M.attached_buffers[buf].chan
	vim.api.nvim_chan_send(chan, data)
end
function M.get_selection(type)
	local selection
	local _, start_row, start_col, _ = unpack(vim.fn.getpos("'["))
	local _, end_row, end_col, _ = unpack(vim.fn.getpos("']"))
	if type == "line" then
		selection = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
	end
	if type == "char" then
		selection = vim.api.nvim_buf_get_text(0, start_row - 1, start_col - 1, end_row - 1, end_col, {})
	end
	if type == "block" then
		selection = {}
		for row = start_row, end_row do
			selection[#selection + 1] = vim.api.nvim_buf_get_text(0, row - 1, start_col - 1, row - 1, end_col, {})[1]
		end
	end
	return selection
end

function M.send_selection(selection, before_send)
	local data = M.selection_to_data(selection)
	local buf = vim.api.nvim_get_current_buf()
	if not M.is_attached(buf) then
		M.setup_buf(buf, function()
			M.send_selection(selection, before_send)
		end)
		return
	end
	if before_send then
		before_send()
	end
	M.send_to_term(buf, data)
end

function M.setup_buf(buf, on_choice)
	if M.is_term(buf) then
		vim.notify("Can't attach a terminal to a terminal", vim.log.levels.WARN)
		return
	end
	local chan_info_list = vim.api.nvim_list_chans()
	local nvim_chan_list = vim.tbl_filter(function(chan_info)
		return chan_info.buffer ~= nil
	end, chan_info_list)
	if vim.tbl_isempty(nvim_chan_list) then
		vim.notify("No terminals to attach to", vim.log.levels.WARN)
		return
	end
	vim.ui.select(nvim_chan_list, {
		prompt = "Select a terminal",
		format_item = function(chan_info)
			return "tbuf : " .. tostring(chan_info.buffer) .. " - " .. table.concat(chan_info.argv, " ")
		end,
	}, function(choice)
		M.attach(buf, choice.buffer, choice.id)
		if on_choice then
			on_choice()
		end
		vim.notify("Terminal attached to buffer")
	end)
end

function M.create_mark(buf, start_row, start_col, end_row, end_col)
	vim.api.nvim_buf_set_extmark(
		buf,
		M.ns,
		start_row,
		start_col,
		{ end_row = end_row, end_col = end_col, hl_group = "Visual" }
	)
end

function M.del_mark(buf, mark)
	vim.api.nvim_buf_del_extmark(buf, M.ns, mark[1])
end

function M.send_mark(buf, mark)
	local detailed_mark = vim.api.nvim_buf_get_extmark_by_id(buf, M.ns, mark[1], { details = true })
	local start_row, start_col, end_row, end_col =
		detailed_mark[1], detailed_mark[2], detailed_mark[3].end_row, detailed_mark[3].end_col
	local selection = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
	M.send_selection(selection)
end

function M.get_marks(buf, start_row, start_col, end_row, end_col)
	local marks = vim.api.nvim_buf_get_extmarks(
		buf,
		M.ns,
		{ start_row, start_col },
		{ end_row, end_col },
		{ overlap = true, details = true }
	)
	if vim.tbl_isempty(marks) then
		return {}
	end
	-- case where one begins after another ends mark_1|mark_2
	-- if the cursor is on the 2nd 'm' you'll get both marks
	local end_row_1 = marks[1][4].end_row
	local end_col_1 = marks[1][4].end_col
	if end_col_1 == start_col and end_row_1 == start_row then
		table.remove(marks, 1)
	end
	return marks
end

function M.get_cursor_mark()
	local buf = vim.api.nvim_get_current_buf()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local marks = M.get_marks(buf, row - 1, col, row - 1, col)
	if vim.tbl_isempty(marks) then
		vim.notify("No mark under cursor", vim.log.levels.INFO)
	elseif #marks == 1 then
		return marks[1]
	else
		vim.notify("Overlapping marks", vim.log.levels.ERROR)
	end
end

Repl.send_operator = function(type)
	local buf = vim.api.nvim_get_current_buf()
	local selection = M.get_selection(type)

	local _, start_row, start_col, _ = unpack(vim.fn.getpos("'["))
	local _, end_row, end_col, _ = unpack(vim.fn.getpos("']"))
	if type == "line" then
		end_col = vim.fn.col({ end_row, "$" }) - 1
	end
	local marks = M.get_marks(buf, start_row - 1, start_col - 1, end_row - 1, end_col)
	for _, mark in ipairs(marks) do
		M.del_mark(buf, mark)
	end
	M.send_selection(selection, function()
		if type ~= "block" then
			M.create_mark(buf, start_row - 1, start_col - 1, end_row - 1, end_col)
		end
	end)
end

vim.keymap.set({ "n", "v" }, "s", function()
	vim.o.operatorfunc = "v:lua.Repl.send_operator"
	vim.api.nvim_input("g@")
end, { desc = "send to term operator" })

vim.keymap.set("n", "<leader>s", function()
	local mark = M.get_cursor_mark()
	if mark then
		M.send_mark(0, mark)
	end
end, { desc = "send mark under cursor" })

vim.keymap.set("n", "<leader>c", function()
	local mark = M.get_cursor_mark()
	if mark then
		M.del_mark(0, mark)
	end
end, { desc = "clear mark under cursor" })
