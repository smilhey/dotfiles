local M = {
	history = { win = -1, buf = -1, messages = {} },
	output = { win = -1, buf = -1 },
	confirm = { win = -1 },
	split_height = 10,
	log = {},
}

function M.add_to_history(lines)
	M.history.messages = vim.iter({ M.history.messages, lines }):flatten():totable()
end

function M.content_to_lines(content)
	local message = ""
	for _, chunk in ipairs(content) do
		message = message .. chunk[2]
	end
	message = string.gsub(message, "\r", "")
	local lines = vim.split(message, "\n")
	while #lines > 1 and lines[#lines] == "" do
		table.remove(lines, #lines)
	end
	while #lines > 1 and lines[1] == "" do
		table.remove(lines, 1)
	end
	return lines
end

function M.clear_buffer(display)
	if vim.api.nvim_buf_is_loaded(M[display].buf) then
		vim.bo[M[display].buf].modifiable = true
		vim.api.nvim_buf_set_lines(M[display].buf, 0, -1, false, {})
		vim.bo[M[display].buf].modifiable = false
	end
end

function M.init_buffer(display)
	if vim.api.nvim_buf_is_loaded(M[display].buf) then
		return
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].filetype = "MsgArea"
	vim.bo[buf].bufhidden = "wipe"
	vim.api.nvim_buf_set_name(buf, "[MsgArea - " .. display .. "]")
	vim.bo[buf].modifiable = false
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(M[display].win, true)
		M[display].win = -1
	end, { buffer = buf, nowait = true, silent = true })
	M[display].buf = buf
end

function M.init_window(display, height)
	if vim.api.nvim_win_is_valid(M[display].win) then
		return
	end
	M.clear_buffer(display)
	M[display].win = vim.api.nvim_open_win(M[display].buf, true, { split = "below" })
	-- getting the split to show at the bottom
	vim.cmd("wincmd J")
	-- minimum height to avoid conflicting with the cmdwindow
	if height < 4 then
		height = 4
	elseif height > M.split_height then
		height = M.split_height
	end
	vim.api.nvim_win_set_height(M[display].win, height)
	vim.wo[M[display].win].winfixbuf = true
end

function M.render_split(display, lines, clear)
	M.init_buffer(display)
	M.init_window(display, #lines)
	local start_line, end_line = 0, -1
	if not clear then
		local buf_lines = vim.api.nvim_buf_get_lines(M[display].buf, 0, -1, true)
		start_line = vim.deep_equal(buf_lines, { "" }) and 0 or #buf_lines
		end_line = -1
	end
	vim.bo[M[display].buf].modifiable = true
	vim.api.nvim_buf_set_lines(M[display].buf, start_line, end_line, false, lines)
	vim.bo[M[display].buf].modifiable = false
end

function M.on_usr_msg(show_kind, lines)
	local text = table.concat(lines, " ")
	if text == "" then
		return
	end
	M.add_to_history(lines)
	if show_kind == "echo" then
		vim.notify(text, vim.log.levels.INFO)
	else
		vim.notify(text, vim.log.levels.ERROR)
	end
end

function M.on_history_show()
	vim.api.nvim_input("<cr>")
	if #M.history.messages == 0 then
		vim.notify("Messages history is emtpy", vim.log.levels.INFO)
		return
	end
	M.render_split("history", M.history.messages, false)
end

function M.on_confirm(kind, lines)
	local text = vim.tbl_filter(function(line)
		return line ~= ""
	end, lines)
	local win_opts = {
		relative = "editor",
		row = vim.o.lines / 2 - 1,
		col = math.floor((vim.o.columns - 30) / 2),
		width = math.max(unpack(vim.tbl_map(function(line)
			return #line
		end, text))),
		height = #text,
		style = "minimal",
		border = "single",
	}
	if kind == "confirm" then
		win_opts.title = text[1]
		win_opts.height = #text - 1
		table.remove(text, 1)
	elseif kind == "confirm_sub" then
		if vim.api.nvim_win_is_valid(M.confirm.win) then
			return
		else
			-- folke trick to get the highlight to show on first replace
			vim.api.nvim_input(" <bs>")
		end
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	M.confirm.win = vim.api.nvim_open_win(buf, false, win_opts)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)
	vim.schedule(function()
		vim.api.nvim_win_close(M.confirm.win, true)
		M.confirm_window = -1
	end)
	vim.cmd("redraw")
end

function M.on_empty(lines)
	if #lines == 1 then
		if string.find(lines[1], "Type  :qa") then
			vim.notify("", vim.log.levels.INFO)
			return
		end
		-- check if the message is a terminal command output
		if lines[1]:find("^:!") then
			vim.notify("shell output", vim.log.levels.INFO)
			return
		end
		M.on_usr_msg("echo", lines)
		return
	end
	vim.schedule(function()
		M.render_split("output", lines, false)
	end)
end

function M.show_log()
	if #M.log == 0 then
		vim.notify("Log is empty", vim.log.levels.INFO)
		return
	end
	M.render_split("output", M.log, true)
end

vim.api.nvim_create_user_command("Mlog", M.show_log, { desc = "Log for messages" })

function M.on_show(...)
	local kind, content, _ = ...
	local lines = M.content_to_lines(content)
	table.insert(M.log, vim.inspect(kind))
	table.insert(M.log, table.concat(lines, "---"))
	if kind == "" then
		M.on_empty(lines)
		return
	elseif kind == "return_prompt" then
		return vim.api.nvim_input("<cr>")
	elseif
		kind == "echo"
		or kind == "emsg"
		or kind == "echomsg"
		or kind == "echoerr"
		or kind == "lua_error"
		or kind == "rpc_error"
	then
		M.on_usr_msg(kind, lines)
		return
	elseif kind == "confirm" or kind == "confirm_sub" then
		M.on_confirm(kind, lines)
	elseif kind == "search_count" or kind == "quickfix" then
		return
	end
end

function M.handler(event, ...)
	if event == "msg_show" then
		M.on_show(...)
	elseif event == "msg_history_show" then
		M.on_history_show()
	else
		-- ignore (showcmd, showmode, showruler, history_clear and msg_clear)
		return
	end
end

function M.notify(msg, log_level, opts)
	if msg == vim.g.status_line_notify.message then
		return
	end
	vim.g.status_line_notify = { message = msg, level = log_level }
	vim.schedule(function()
		vim.cmd("redrawstatus")
	end)
end

function M.attach()
	vim.ui_attach(M.namespace, { ext_messages = true }, function(event, ...)
		M.handler(event, ...)
		if event:match("msg") ~= nil then
			return true
		end
		return false
	end)
end

function M.detach()
	vim.ui_detach(M.namespace)
end

function M.init()
	vim.notify = M.notify
	M.namespace = vim.api.nvim_create_namespace("Msg")
	M.attach()
end

return M
