local M = {
	history = { window = -1, buffer = -1, messages = {} },
	output = { window = -1, buffer = -1 },
	confirm = { window = -1 },
	split_height = 7,
}

function M.content_to_lines(content)
	local message = ""
	for _, chunk in ipairs(content) do
		message = message .. chunk[2]
	end
	message = string.gsub(message, "\r", "")
	return vim.split(message, "\n")
end

function M.clear_buffer(display)
	if vim.api.nvim_buf_is_loaded(M[display].buffer) then
		vim.bo[M[display].buffer].modifiable = true
		vim.api.nvim_buf_set_lines(M[display].buffer, 0, -1, false, {})
		vim.bo[M[display].buffer].modifiable = false
	end
end

function M.init_buffer(display)
	if vim.api.nvim_buf_is_loaded(M[display].buffer) then
		return
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].filetype = "MsgArea"
	vim.bo[buf].bufhidden = "wipe"
	vim.api.nvim_buf_set_name(buf, "[MsgArea - " .. display .. "]")
	vim.bo[buf].modifiable = false
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(M[display].window, true)
		M[display].window = -1
	end, { buffer = buf, nowait = true, silent = true })
	M[display].buffer = buf
end

function M.init_window(display)
	if vim.api.nvim_win_is_valid(M[display].window) then
		return
	end
	M.clear_buffer(display)
	M[display].window = vim.api.nvim_open_win(M[display].buffer, true, { split = "below" })
	-- getting the split to show at the bottom
	vim.cmd("wincmd J")
	vim.api.nvim_win_set_height(M[display].window, M.split_height)
	vim.wo[M[display].window].winfixbuf = true
end

function M.render_split(display, lines, clear)
	M.init_buffer(display)
	M.init_window(display)
	local start_line, end_line = 0, -1
	if not clear then
		local buf_lines = vim.api.nvim_buf_get_lines(M[display].buffer, 0, -1, true)
		start_line = vim.deep_equal(buf_lines, { "" }) and 0 or #buf_lines
		end_line = -1
	end
	vim.bo[M[display].buffer].modifiable = true
	vim.api.nvim_buf_set_lines(M[display].buffer, start_line, end_line, false, lines)
	vim.bo[M[display].buffer].modifiable = false
end

function M.on_usr_msg(show_kind, lines)
	M.history.messages = vim.iter({ M.history.messages, lines }):flatten():totable()
	local text = table.concat(lines, "\n")
	if text == "" then
		return
	end
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
		width = math.max(unpack(vim.tbl_map(function(line)
			return #line
		end, text))),
		height = #text,
		row = vim.o.lines / 2 - 1,
		col = math.floor((vim.o.columns - 30) / 2),
		style = "minimal",
		border = "single",
	}
	if kind == "confirm" then
		win_opts.title = text[1]
		win_opts.height = #text - 1
	elseif kind == "confirm_sub" then
		if vim.api.nvim_win_is_valid(M.confirm.window) then
			return
		else
			-- folke trick to get the highlight to show on first replace
			vim.api.nvim_input(" <bs>")
		end
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	M.confirm.window = vim.api.nvim_open_win(buf, false, win_opts)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)
	vim.schedule(function()
		vim.api.nvim_win_close(M.confirm.window, true)
		M.confirm_window = -1
	end)
	vim.cmd("redraw")
end

function M.on_empty(lines)
	if #lines == 1 then
		M.on_usr_msg("echo", lines)
		return
	end
	-- check if the message is a terminal command output
	if lines[1]:find("^:!") then
		table.remove(lines, 1)
	end
	vim.schedule(function()
		M.render_split("output", lines, false)
	end)
end

function M.on_show(...)
	local kind, content, _ = ...
	local lines = M.content_to_lines(content)
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
	vim.g.status_line_notify = { message = msg, level = log_level }
	vim.schedule(function()
		vim.cmd("redrawstatus!")
	end)
	vim.defer_fn(function()
		vim.g.status_line_notify = { message = "", level = nil }
		vim.schedule(function()
			vim.cmd("redrawstatus!")
		end)
	end, 3000)
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
	M.namespace = vim.api.nvim_create_namespace("CustomMsgArea")
	M.attach()
	-- Best way to get to see what you're typing without handling cmdline
	-- messages the output in still handled our handler
	-- ui.input and ui.select are overriden elsewhere
	local fn_input = vim.fn.input
	local fn_inputlist = vim.fn.inputlist
	local fn_getchar = vim.fn.getchar
	local fn_getcharstr = vim.fn.getcharstr
	local wrap = function(fn)
		local wrapped_fn = function(...)
			M.detach()
			vim.cmd("redraw")
			local input = fn(...)
			M.attach()
			vim.cmd("redraw")
			return input
		end
		return wrapped_fn
	end
	vim.fn.input = wrap(fn_input)
	vim.fn.inputlist = wrap(fn_inputlist)
	vim.fn.getchar = wrap(fn_getchar)
	vim.fn.getcharstr = wrap(fn_getcharstr)
end

return M
