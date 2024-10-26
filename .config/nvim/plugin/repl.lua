Repl = {}
local M = {
	chans = {},
	outputs = {},
	output_queue = {},
	jobs = {},
	opts = { display = { mode = "virt", height = 8, row_offset = 0 } },
	run = {},
}

M.autogroup = vim.api.nvim_create_augroup("repl", { clear = true })

M.ns = vim.api.nvim_create_namespace("repl")

M.ns_outputs = vim.api.nvim_create_namespace("repl-outputs")

M.supported_repls = { "ipython", "python", "luajit" }

M.commentstring = {
	luajit = "--",
	python = "#",
	ipython = "#",
}

M.format_input = {
	luajit = function(selection)
		local lines = vim.tbl_filter(function(line)
			return line ~= ""
		end, selection)
		return table.concat(lines, "\n") .. "\r"
	end,
	python = function(selection)
		local input = ""
		local lines = vim.tbl_filter(function(line)
			return line ~= ""
		end, selection)
		for i, line in ipairs(lines) do
			line = line .. "\r"
			local indentation = #line:match("^%s*")
			if i == #lines and indentation > 0 then
				line = line .. "\r"
			end
			input = input .. line
		end
		return input
	end,
	ipython = function(selection)
		local input = ""
		local lines = vim.tbl_filter(function(line)
			return line ~= ""
		end, selection)
		for i, line in ipairs(lines) do
			line = line .. "\r"
			local indentation = #line:match("^%s*")
			if i == #lines and indentation > 0 then
				line = line .. "\r"
			end
			input = input .. line
		end
		return input
	end,
}

M.format_output = {
	luajit = function(data)
		local lines = {}
		for _, line in ipairs(data) do
			line = line:gsub("> ", "")
			line = line:gsub("[>\r]", "")
			local is_output = line:find(M.commentstring.luajit .. "IN") == nil
				and line:find("[MARK ", 1, true) == nil
				and line ~= ""
			lines[#lines + 1] = is_output and line or nil
		end
		return lines
	end,
	python = function(data)
		local lines = {}
		for _, line in ipairs(data) do
			line = line:gsub("\r", "")
			local is_input = line:find(M.commentstring.python .. "IN") ~= nil or line:find("[MARK ", 1, true) ~= nil

			lines[#lines + 1] = not is_input and line or nil
		end
		return lines
	end,
	ipython = function(data)
		local lines = {}
		for _, line in ipairs(data) do
			line = line:gsub("\27%[[0-9;?]*[a-zA-Z]", "")
			line = line:gsub("\r", "")
			local is_output = line:find("In %[") == nil
				and line:find("   ...:") == nil
				and line:find(M.commentstring.python .. "IN") == nil
				and line:find("[MARK ", 1, true) == nil
				and line ~= ""
			lines[#lines + 1] = is_output and line or nil
		end
		return lines
	end,
}

function M.is_attached(buf)
	return M.chans[buf] and not vim.tbl_isempty(vim.api.nvim_get_chan_info(M.chans[buf]))
end

function M.is_job(chan)
	return vim.tbl_contains(M.jobs, chan, {})
end

function M.get_repl(chan)
	local chan_info = vim.api.nvim_get_chan_info(chan)
	local cmd = table.concat(chan_info.argv, " ")
	for _, repl in ipairs(M.supported_repls) do
		if cmd:find(repl) ~= nil then
			return repl
		end
	end
	vim.notify("repl not supported", vim.log.levels.WARN)
	return nil
end

function M.attach(buf, chan)
	if M.opts.display.mode == "float" then
		vim.api.nvim_create_autocmd("BufLeave", {
			buffer = buf,
			desc = "clearing repl output windows",
			callback = function()
				for mark, output in pairs(M.outputs[buf]) do
					if vim.api.nvim_win_is_valid(output.win) then
						vim.api.nvim_win_close(output.win, true)
					end
					vim.api.nvim_buf_del_extmark(buf, M.ns_outputs, mark)
				end
			end,
		})
		vim.api.nvim_create_autocmd({ "BufEnter", "WinScrolled" }, {
			buffer = buf,
			desc = "reopening repl output windows",
			callback = function()
				for mark, output in pairs(M.outputs[buf]) do
					local start_row = vim.fn.getpos("w0")[2]
					local end_row = vim.fn.getpos("w$")[2]
					local mark_info = vim.api.nvim_buf_get_extmark_by_id(buf, M.ns, mark, { details = true })
					if not vim.tbl_isempty(mark_info) then
						if vim.api.nvim_win_is_valid(output.win) then
							if mark_info[3].end_row < start_row or mark_info[3].end_row > end_row then
								vim.api.nvim_win_close(output.win, true)
								vim.api.nvim_buf_del_extmark(buf, M.ns_outputs, mark)
							end
						else
							if mark_info[3].end_row >= start_row and mark_info[3].end_row <= end_row then
								M.display_output(buf, mark, M.opts.display.mode)
							end
						end
					end
				end
			end,
		})
	end
	if M.is_job(chan) then
		M.outputs[buf] = {}
		M.output_queue[chan] = M.output_queue[chan] and M.output_queue[chan] or {}
		M.run[chan] = M.run[chan] and M.run[chan] or false
	end
	M.chans[buf] = chan
end

function M.detach(buf)
	M.chans[buf] = nil
end

function M.init_repl(buf)
	local chan_info_list = vim.api.nvim_list_chans()
	local nvim_chan_list = vim.tbl_filter(function(chan_info)
		return chan_info.pty ~= nil
	end, chan_info_list)
	nvim_chan_list[#nvim_chan_list + 1] = "Launch a repl as a job"
	local format_item = function(chan_info)
		if type(chan_info) == "string" then
			return chan_info
		end
		local tbuf = chan_info.buffer
		local term = tbuf and "tbuf : " .. tostring(chan_info.buffer) or "job"
		local argv = chan_info.argv
		local cmd = argv and table.concat(argv, " ") or " "
		return term .. " - " .. cmd
	end
	local on_choice = function(choice)
		local chan = type(choice) == "string"
		if type(choice) == "string" then
			local cmd = vim.fn.input({ prompt = "Enter a repl command : " })
			if cmd == "" then
				vim.notify("A command is needed to launch a repl", vim.log.levels.WARN)
				return
			end
			cmd = vim.split(cmd, " ")
			chan = M.job_launch(cmd)
		else
			chan = choice.id
		end
		M.attach(buf, chan)
		vim.notify("Terminal attached to buffer")
	end
	vim.ui.select(nvim_chan_list, {
		prompt = "Select a terminal",
		format_item = format_item,
	}, on_choice)
end

function M.set_output_info(buf, mark)
	local chan = M.chans[buf]
	M.outputs[buf][mark] = { data = {}, win = -1 }
	M.output_queue[chan][#M.output_queue[chan] + 1] = { buf, mark }
end

function M.display_output(buf, mark, mode)
	local row = vim.api.nvim_buf_get_extmark_by_id(buf, M.ns, mark, { details = true })[3].end_row
	local repl = M.get_repl(M.chans[buf])
	local lines = M.format_output[repl](M.outputs[buf][mark].data)
	local len = M.opts.display.height > #lines and #lines or M.opts.display.height
	if mode == "virt" then
		local virt_lines = {}
		for i = 1, len do
			virt_lines[#virt_lines + 1] = { { lines[i], "Comment" } }
		end
		if M.opts.display.height < #lines then
			virt_lines[#virt_lines + 1] =
				{ { "... [" .. tostring(#lines - M.opts.display.height) .. " - lines]", "Comment" } }
		end
		vim.api.nvim_buf_set_extmark(buf, M.ns_outputs, row, 0, { id = mark, virt_lines = virt_lines })
	elseif mode == "float" then
		local virt_pad = {}
		for i = 1, len + 2 do
			virt_pad[i] = { { "" } }
		end
		if #lines > 0 then
			vim.api.nvim_buf_set_extmark(buf, M.ns_outputs, row, 0, { id = mark, virt_lines = virt_pad })
		end
		local output_buf = vim.api.nvim_create_buf(false, true)
		local output_win = #lines > 0
				and vim.api.nvim_open_win(output_buf, false, {
					relative = "win",
					bufpos = { row, 0 },
					width = vim.o.columns,
					height = #lines < M.opts.display.height and #lines or M.opts.display.height,
					border = { "", "-", "", "", "", "-", "", "" },
				})
			or -1
		vim.keymap.set("n", "q", "<cmd>close!<cr>", { buffer = output_buf })
		vim.api.nvim_buf_set_lines(output_buf, 0, -1, false, lines)
		M.outputs[buf][mark].win = output_win
	end
end

function M.check_end(data)
	for i, str in ipairs(data) do
		if str:find("[MARK END]", 1, true) then
			return i
		end
	end
	return 0
end

function M.check_start(data)
	for _, str in ipairs(data) do
		if str:find("[MARK START]", 1, true) then
			return true
		end
	end
	return false
end

function M.on_output(chan, data)
	if M.check_start(data) then
		M.run[chan] = true
	end
	if M.run[chan] then
		local buf, mark = unpack(M.output_queue[chan][1])
		local end_signal_index = M.check_end(data)
		if end_signal_index > 0 then
			table.remove(M.output_queue[chan], 1)
			if end_signal_index > 1 then
				data = vim.iter(data):take(end_signal_index - 1):totable()
				M.outputs[buf][mark].data = vim.iter({ M.outputs[buf][mark].data, data }):flatten():totable()
			end
			M.display_output(buf, mark, M.opts.display.mode)
			M.run[chan] = false
		else
			M.outputs[buf][mark].data = vim.iter({ M.outputs[buf][mark].data, data }):flatten():totable()
		end
	else
		-- vim.notify("Received output without sending mark")
	end
end

function M.job_launch(cmd)
	local buf = vim.api.nvim_create_buf(true, false)
	local win = vim.api.nvim_open_win(
		buf,
		true,
		{ relative = "editor", width = vim.o.columns, height = vim.o.lines, col = 0, row = 1 }
	)
	local chan = vim.fn.termopen(cmd, {
		on_stdout = M.on_output,
		on_exit = function()
			vim.notify("Job over", vim.log.levels.INFO)
		end,
	})
	vim.api.nvim_win_close(win, true)
	M.jobs[#M.jobs + 1] = chan
	return chan
end

function M.send_selection(buf, selection)
	local chan = M.chans[buf]
	local repl = M.get_repl(chan)
	local data = M.format_input[repl](selection)
	vim.api.nvim_chan_send(chan, data)
end

function M.create_mark(buf, start_row, start_col, end_row, end_col)
	return vim.api.nvim_buf_set_extmark(
		buf,
		M.ns,
		start_row,
		start_col,
		{ end_row = end_row, end_col = end_col, hl_group = "Visual" }
	)
end

function M.del_mark(buf, mark)
	if vim.api.nvim_win_is_valid(M.outputs[buf][mark].win) then
		vim.api.nvim_win_close(M.outputs[buf][mark].win, true)
	end
	vim.api.nvim_buf_del_extmark(buf, M.ns_outputs, mark)
	vim.api.nvim_buf_del_extmark(buf, M.ns, mark)
end

function M.send_mark(buf, mark)
	local mark_info = vim.api.nvim_buf_get_extmark_by_id(buf, M.ns, mark, { details = true })
	local start_row, start_col, end_row, end_col =
		mark_info[1], mark_info[2], mark_info[3].end_row, mark_info[3].end_col
	local selection = vim.api.nvim_buf_get_text(buf, start_row, start_col, end_row, end_col, {})

	local chan = M.chans[buf]
	if M.is_job(chan) then
		selection = vim.tbl_map(function(str)
			return str .. " " .. M.commentstring[M.get_repl(chan)] .. "IN"
		end, selection)
		table.insert(
			selection,
			1,
			(" "):rep(40) .. M.commentstring[M.get_repl(chan)] .. "[MARK START] : " .. buf .. " - " .. mark
		)
		M.set_output_info(buf, mark)
	end
	M.send_selection(buf, selection)
	if M.is_job(chan) then
		vim.wait(10, function() end)
		M.send_selection(buf, { (" "):rep(40) .. M.commentstring[M.get_repl(chan)] .. "[MARK END]" })
	end
end

function M.get_marks(buf, start_row, start_col, end_row, end_col)
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

function M.send_range(buf, start_row, end_row, start_col, end_col)
	start_col = start_col and start_col or 0
	end_col = end_col and end_col or vim.fn.col({ end_row + 1, "$" }) - 1
	local marks = M.get_marks(buf, start_row, start_col, end_row, end_col)
	for _, mark in ipairs(marks) do
		M.del_mark(buf, mark)
	end
	local mark = M.create_mark(buf, start_row, start_col, end_row, end_col)
	M.send_mark(buf, mark)
end

Repl.send_operator = function(type)
	local buf = vim.api.nvim_get_current_buf()
	if not M.is_attached(buf) then
		M.init_repl(buf)
		return
	end
	local _, start_row, start_col, _ = unpack(vim.fn.getpos("'["))
	local _, end_row, end_col, _ = unpack(vim.fn.getpos("']"))
	if type == "line" then
		M.send_range(buf, start_row - 1, end_row - 1)
	else
		M.send_range(buf, start_row - 1, end_row - 1, start_col - 1, end_col)
	end
end

vim.keymap.set({ "n", "v" }, "s", function()
	vim.o.operatorfunc = "v:lua.Repl.send_operator"
	vim.api.nvim_input("g@")
end, { desc = "send to term operator" })

vim.keymap.set("n", "<leader>ss", function()
	local mark = M.get_cursor_mark()
	if mark then
		M.send_mark(vim.api.nvim_get_current_buf(), mark)
	end
end, { desc = "send mark under cursor" })

vim.keymap.set("n", "<leader>so", function()
	local buf = vim.api.nvim_get_current_buf()
	local mark = M.get_cursor_mark()
	if mark then
		M.display_output(buf, mark, "float")
	end
end, { desc = "send mark under cursor" })

vim.keymap.set("n", "<leader>sd", function()
	local buf = vim.api.nvim_get_current_buf()
	M.detach(buf)
end, { desc = "send mark under cursor" })

vim.keymap.set("n", "<leader>c", function()
	local mark = M.get_cursor_mark()
	if mark then
		M.del_mark(vim.api.nvim_get_current_buf(), mark)
	end
end, { desc = "clear mark under cursor" })

vim.keymap.set("n", "<leader>sa", function()
	local query
	if vim.bo.filetype == "markdown" then
		_, query = pcall(vim.treesitter.query.parse, "markdown", [[ (code_fence_content)  @codeblock ]])
	else
		_, query = pcall(vim.treesitter.query.parse, "norg", [[ (ranged_verbatim_tag_content)  @codeblock ]])
	end
	local buf = vim.api.nvim_get_current_buf()
	local parser = vim.treesitter.get_parser(buf)
	local tree = parser:parse()
	local root = tree[1]:root()
	for _, match in query:iter_matches(root, buf) do
		for id, nodes in pairs(match) do
			local name = query.captures[id]
			if name == "codeblock" then
				local node = nodes[#nodes]
				local start_row, _, end_row, _ = node:range()
				M.send_range(buf, start_row, end_row - 1)
			end
		end
	end
end)
