local M = {
	history = { win = -1, buf = -1, messages = {} },
	output = { win = -1, buf = -1 },
	confirm = { win = -1 },
	split_height = 10,
	log = {},
}

function M.content_to_lines(content)
	local msg = ""
	for _, chunk in ipairs(content) do
		msg = msg .. chunk[2]
	end
	msg = string.gsub(msg, "\r", "")
	local lines = vim.split(msg, "\n")
	while #lines > 1 and lines[#lines] == "" do
		table.remove(lines, #lines)
	end
	while #lines > 1 and lines[1] == "" do
		table.remove(lines, 1)
	end
	return lines
end

function M.clear_buf(display)
	if vim.api.nvim_buf_is_loaded(M[display].buf) then
		vim.bo[M[display].buf].modifiable = true
		vim.api.nvim_buf_set_lines(M[display].buf, 0, -1, false, {})
		vim.bo[M[display].buf].modifiable = false
	end
end

function M.init_buf(display)
	if vim.api.nvim_buf_is_loaded(M[display].buf) then
		return
	end
	local buf = vim.api.nvim_create_buf(false, true)
	-- vim.bo[buf].filetype = "MsgArea"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false
	vim.api.nvim_buf_set_name(buf, "[MsgArea - " .. display .. "]")
	vim.keymap.set("n", "q", function()
		pcall(vim.api.nvim_win_close, M[display].win, true)
		M[display].win = -1
	end, { buffer = buf, nowait = true, silent = true })
	M[display].buf = buf
end

function M.init_win(display, height)
	if vim.api.nvim_win_is_valid(M[display].win) then
		return
	end
	M.clear_buf(display)
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
	if vim.api.nvim_win_get_config(0).relative ~= "" then
		vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
		return
	end
	M.init_buf(display)
	M.init_win(display, #lines)
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
	local msg = table.concat(lines, "\n")
	if msg == "" then
		return
	end
	if show_kind == "echo" then
		vim.notify(msg, vim.log.levels.INFO)
	else
		vim.notify(msg, vim.log.levels.ERROR)
	end
end

function M.on_history_show()
	if #M.history.messages == 0 then
		vim.notify("Messages history is empty", vim.log.levels.INFO)
		return
	end
	M.render_split("history", M.history.messages, true)
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
		vim.opt.hlsearch = true
		vim.api.nvim__redraw({ flush = true, cursor = true })
		if vim.api.nvim_win_is_valid(M.confirm.win) then
			return
		end
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	M.confirm.win = vim.api.nvim_open_win(buf, false, win_opts)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)
	vim.schedule(function()
		vim.api.nvim_win_close(M.confirm.win, true)
		M.confirm.win = -1
		vim.opt.hlsearch = false
	end)
	vim.api.nvim__redraw({ flush = true, cursor = true })
end

function M.clear_search_count()
	vim.defer_fn(function()
		if vim.v.hlsearch == 0 then
			vim.api.nvim_buf_del_extmark(0, M.ns, M.search_mark)
		else
			M.clear_search_count()
		end
	end, 50)
end

function M.on_search_count(lines)
	vim.opt.hlsearch = true
	M.clear_search_count()
	vim.schedule(function()
		local search_count = lines[1]:sub(lines[1]:find("[", 1, true), -1)
		local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		if M.search_mark then
			M.search_mark = vim.api.nvim_buf_set_extmark(
				0,
				M.ns,
				line - 1,
				col,
				{ id = M.search_mark, virt_text = { { search_count, "Search" } } }
			)
		else
			M.search_mark =
				vim.api.nvim_buf_set_extmark(0, M.ns, line - 1, col, { virt_text = { { search_count, "Search" } } })
		end
	end)
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
	elseif vim.tbl_contains({ "rpc_error", "lua_error", "echoerr", "echomsg", "emsg", "echo", "wmsg" }, kind) then
		M.on_usr_msg(kind, lines)
		return
	elseif kind == "confirm" or kind == "confirm_sub" then
		M.on_confirm(kind, lines)
	elseif kind == "search_count" then
		M.on_search_count(lines)
	elseif kind == "quickfix" then
		return
	end
end

function M.handler(event, ...)
	if event == "msg_show" then
		M.on_show(...)
	elseif event == "msg_history_show" then
		M.on_history_show()
	else -- ignore (showcmd, showmode, showruler, history_clear and msg_clear)
		return
	end
end

function M.add_to_history(msg)
	local lines = vim.fn.split(msg, "\n")
	M.history.messages = vim.iter({ M.history.messages, lines }):flatten():totable()
end

function M.setup()
	M.ns = vim.api.nvim_create_namespace("messages")
end

return M
