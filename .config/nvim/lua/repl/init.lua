local format = require("repl.format")
local output = require("repl.output")
local cells = require("repl.cells")
local utils = require("repl.utils")

local M = {
	chans = {},
}

M.group = vim.api.nvim_create_augroup("repl", { clear = true })
M.ns = vim.api.nvim_create_namespace("repl")

function M.is_attached(buf)
	return M.chans[buf] and not vim.tbl_isempty(vim.api.nvim_get_chan_info(M.chans[buf]))
end

function M.attach(buf, chan)
	if output.enabled[chan] then
		if output.opts.display.float then
			vim.api.nvim_create_autocmd("BufWinEnter", {
				group = M.group,
				buffer = buf,
				desc = "clear repl output float",
				callback = function()
					local entered_win = vim.api.nvim_get_current_win()
					if vim.api.nvim_win_get_config(entered_win).relative ~= nil then
						return
					end
					if vim.api.nvim_win_is_valid(output.float.win) then
						vim.api.nvim_win_close(output.float.win, true)
						vim.api.nvim_buf_del_extmark(buf, output.ns, output.float.mark)
					end
				end,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved" }, {
				group = M.group,
				buffer = buf,
				desc = "open repl output float",
				callback = function()
					local mark = M.get_cursor_mark()
					if mark then
						if not vim.api.nvim_win_is_valid(output.float.win) then
							M.display_output_float(buf, mark)
						end
					else
						if vim.api.nvim_win_is_valid(output.float.win) then
							vim.api.nvim_win_close(output.float.win, true)
							vim.api.nvim_buf_del_extmark(buf, output.ns, output.float.mark)
							M.float.win = -1
						end
					end
				end,
			})
		end
		output.data[buf] = {}
		output.queue[chan] = output.queue[chan] and output.queue[chan] or {}
		output.is_running[chan] = output.is_running[chan] and output.is_running[chan] or false
	end
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		group = M.group,
		buffer = buf,
		desc = "highlight mark under cursor",
		callback = function()
			local mark = M.get_cursor_mark()
			if mark then
				M.cur_mark = mark
				local mark_info = vim.api.nvim_buf_get_extmark_by_id(buf, cells.ns, mark, { details = true })
				vim.api.nvim_buf_set_extmark(
					buf,
					cells.ns,
					mark_info[1],
					mark_info[2],
					{ id = mark, end_row = mark_info[3].end_row, end_col = mark_info[3].end_col, hl_group = "Visual" }
				)
			elseif M.cur_mark then
				local mark_info = vim.api.nvim_buf_get_extmark_by_id(buf, cells.ns, M.cur_mark, { details = true })
				if vim.tbl_isempty(mark_info) then
					M.cur_mark = nil
				else
					vim.api.nvim_buf_set_extmark(buf, cells.ns, mark_info[1], mark_info[2], {
						id = M.cur_mark,
						end_row = mark_info[3].end_row,
						end_col = mark_info[3].end_col,
					})
				end
			end
		end,
	})
	M.chans[buf] = chan
end

function M.detach(buf)
	M.chans[buf] = nil
end

function M.init_term(buf)
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
			chan = M.start_job(cmd)
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

function M.start_job(cmd)
	local buf = vim.api.nvim_create_buf(true, false)
	local win = vim.api.nvim_open_win(
		buf,
		true,
		{ relative = "editor", width = vim.o.columns, height = vim.o.lines, col = 0, row = 1 }
	)
	local chan = vim.fn.termopen(cmd, {
		on_stdout = output.process,
		on_exit = function()
			vim.notify("Job over", vim.log.levels.INFO)
		end,
	})
	vim.api.nvim_win_close(win, true)
	local repl = cmd[1]
	if vim.tbl_contains(format.supported, repl) then
		output.enabled[chan] = true
	end
	return chan
end

function M.get_cursor_mark()
	local buf = vim.api.nvim_get_current_buf()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local marks = cells.get(buf, row - 1, col, row - 1, col)
	if #marks == 1 then
		return marks[1]
	elseif #marks > 1 then
		vim.notify("Overlapping marks", vim.log.levels.ERROR)
	end
end

function M.send_range(buf, start_row, end_row, start_col, end_col)
	start_col = start_col and start_col or 0
	end_col = end_col and end_col or vim.fn.col({ end_row + 1, "$" }) - 1
	local marks = cells.get(buf, start_row, start_col, end_row, end_col)
	for _, mark in ipairs(marks) do
		cells.del(buf, mark)
	end
	local mark = cells.set(buf, start_row, start_col, end_row, end_col)
	cells.send(M.chans[buf], buf, mark)
end

M.send_operator = function(type)
	local buf = vim.api.nvim_get_current_buf()
	if not M.is_attached(buf) then
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

vim.keymap.set({ "n", "v" }, "s", function()
	vim.o.operatorfunc = "v:lua.require'repl'.send_operator"
	vim.api.nvim_input("g@")
end, { desc = "send to term operator" })

vim.keymap.set("n", "<leader>ss", function()
	local buf = vim.api.nvim_get_current_buf()
	if not M.is_attached(buf) then
		M.init_term(buf)
		return
	end
	local mark = M.get_cursor_mark()
	if mark then
		cells.send(M.chans[buf], vim.api.nvim_get_current_buf(), mark)
	else
		vim.notify("No mark under cursor", vim.log.levels.INFO)
	end
end, { desc = "Send mark under cursor" })

vim.keymap.set("n", "<leader>c", function()
	local mark = M.get_cursor_mark()
	if mark then
		cells.del(vim.api.nvim_get_current_buf(), mark)
	else
		vim.notify("No mark under cursor", vim.log.levels.INFO)
	end
end, { desc = "Clear mark under cursor" })

vim.keymap.set("n", "<leader>si", function()
	local buf = vim.api.nvim_get_current_buf()
	local chan = M.chans[buf]
	if output.enabled[chan] then
		if not vim.tbl_isempty(output.queue) then
			for _, cell in ipairs(output.queue[chan]) do
				cells.del(cell.buf, cell.mark)
			end
		end
		output.queue[chan] = {}
	end
	utils.send_selection(chan, { string.char(0x03) })
end, { desc = "Send interrupt signal" })

vim.keymap.set("n", "<leader>so", function()
	local buf = vim.api.nvim_get_current_buf()
	local repl = utils.get_repl(M.chans[buf])
	local mark = M.get_cursor_mark()
	if mark then
		output.display_float(repl, buf, mark)
	end
end, { desc = "Send mark under cursor" })

vim.keymap.set("n", "<leader>sd", function()
	local buf = vim.api.nvim_get_current_buf()
	M.detach(buf)
end, { desc = "Detach " })

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
end)

return M
