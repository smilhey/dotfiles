local format = require("repl.format")
local handlers = require("repl.handlers")
local cells = require("repl.cells")

local M = {
	handlers = {},
}

M.group = vim.api.nvim_create_augroup("repl", { clear = true })
M.ns = vim.api.nvim_create_namespace("repl")

function M.is_attached(buf)
	return M.handlers[buf] and not vim.tbl_isempty(vim.api.nvim_get_chan_info(M.handlers[buf].chan))
end

function M.attach(buf, chan, receive)
	local handler
	for _, h in ipairs(M.handlers) do
		if h.chan == chan then
			handler = h
		end
	end
	handler = handler or handlers.init(chan, receive)
	handler:attach(buf)
	M.handlers[buf] = handler
end

function M.detach(buf)
	local h = M.handlers[buf]
	h:clear_queue(buf)
	M.handlers[buf] = nil
	cells.clear_all(buf)
end

function M.init_term(buf)
	local chan_info_list = vim.api.nvim_list_chans()
	local available_terms = vim.tbl_filter(function(chan_info)
		return chan_info.pty ~= nil
	end, chan_info_list)
	available_terms[#available_terms + 1] = "Launch a repl as a job"
	local on_choice = function(choice)
		if type(choice) == "string" then
			local cmd = vim.fn.input({ prompt = "Enter a REPL command : " })
			if cmd == "" then
				vim.notify("A command is required to launch a REPL", vim.log.levels.WARN)
				return
			end
			cmd = vim.split(cmd, " ")
			M.attach(buf, M.start_job(cmd))
		else
			M.attach(buf, choice.id, false)
		end
		vim.notify("Terminal attached to buffer")
	end
	local format_item = function(chan_info)
		if type(chan_info) == "string" then
			return chan_info
		end
		local term = chan_info.buffer and "tbuf : " .. tostring(chan_info.buffer) or "job"
		local cmd = chan_info.argv and table.concat(chan_info.argv, " ") or "<unknown>"
		return term .. " - " .. cmd
	end
	vim.ui.select(available_terms, {
		prompt = "Select a terminal",
		format_item = format_item,
	}, on_choice)
end

function M.start_job(cmd)
	local t_buf = vim.api.nvim_create_buf(true, false)
	local win = vim.api.nvim_open_win(
		t_buf,
		true,
		{ relative = "editor", width = vim.o.columns, height = vim.o.lines, col = 0, row = 1 }
	)
	local chan
	local clear = function()
		for b, _ in ipairs(M.handlers) do
			M.detach(b)
		end
	end
	local on_output = function(c, d, _)
		for _, h in ipairs(M.handlers) do
			if h.chan == c then
				h:on_output(d)
			end
		end
	end
	chan = vim.fn.termopen(cmd, {
		on_stdout = on_output,
		on_stderr = clear,
		on_exit = clear,
	})
	vim.api.nvim_win_close(win, true)
	local repl = cmd[1]
	local receive = vim.tbl_contains(format.supported, repl)
	return chan, receive
end

function M.send_range(buf, start_row, end_row, start_col, end_col)
	start_col = start_col and start_col or 0
	end_col = end_col and end_col or vim.fn.col({ end_row + 1, "$" }) - 1
	cells.clear_range(buf, start_row, start_col, end_row, end_col)
	local cell = cells.create(buf, { start_row, start_col, end_row, end_col })
	M.handlers[buf]:add_to_queue(cell)
	M.handlers[buf]:process_queue()
end

M.send_operator = function(type)
	local buf = vim.api.nvim_get_current_buf()
	if not M.is_attached(buf) then
		vim.notify("No REPL attached to this buffer", vim.log.levels.WARN)
		M.init_term(buf)
		return
	end
	local _, start_row, start_col, _ = unpack(vim.fn.getpos("'["))
	local _, end_row, end_col, _ = unpack(vim.fn.getpos("']"))
	if type == "char" then
		M.send_range(buf, start_row - 1, end_row - 1, start_col - 1, end_col)
	else
		M.send_range(buf, start_row - 1, end_row - 1)
	end
end

function M.with_cur_cell(fn)
	local buf = vim.api.nvim_get_current_buf()
	local handler = M.handlers[buf]
	if not M.is_attached(buf) then
		M.init_term(buf)
		vim.notify("No REPL attached to this buffer", vim.log.levels.WARN)
		return
	end
	local cell = handler:get_cursor_cell()
	if cell then
		fn(cell, buf)
	else
		vim.notify("No cell under cursor", vim.log.levels.INFO)
	end
end

vim.keymap.set({ "n", "v" }, "s", function()
	vim.o.operatorfunc = "v:lua.require'repl'.send_operator"
	vim.api.nvim_input("g@")
end, { desc = "send to term operator" })

vim.keymap.set("n", "<leader>ss", function()
	M.with_cur_cell(function(cell)
		M.handlers[cell.buf]:add_to_queue(cell)
		M.handlers[cell.buf]:process_queue()
	end)
end, { desc = "Send cell under cursor" })

vim.keymap.set("n", "<leader>c", function()
	M.with_cur_cell(function(cell)
		cell:clear()
	end)
end, { desc = "Clear cell under cursor" })

vim.keymap.set("n", "<leader>si", function()
	local buf = vim.api.nvim_get_current_buf()
	local handler = M.handlers[buf]
	handler:interrupt()
end, { desc = "Send interrupt signal" })

vim.keymap.set("n", "<leader>so", function()
	M.with_cur_cell(function(cell)
		cell:display_float()
	end)
end, { desc = "Send mark under cursor" })

vim.keymap.set("n", "<leader>sc", function()
	M.with_cur_cell(function(cell)
		cell:clear_float()
	end)
end, { desc = "Clear cell float under cursor" })

vim.keymap.set("n", "<leader>sd", function()
	local buf = vim.api.nvim_get_current_buf()
	M.detach(buf)
end, { desc = "Detach" })

vim.keymap.set("n", "<leader>sa", function()
	local query
	if vim.bo.filetype == "markdown" then
		_, query = pcall(vim.treesitter.query.parse, "markdown", [[ (code_fence_content)  @codeblock ]])
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
end, { desc = "Send all code blocks" })

return M
