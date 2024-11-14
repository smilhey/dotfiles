local format = require("repl.format")
local utils = require("repl.utils")

local M = {
	data = {},
	queue = {},
	enabled = {},
	is_closed = {},
	is_running = {},
	opts = { display = { virt = false, float = true, output_height = 8, output_offset = true } },
	float = { win = -1, buf = -1 },
	ns = vim.api.nvim_create_namespace("output"),
}

local function get_output_row(buf, mark)
	local cells_ns = vim.api.nvim_get_namespaces()["cells"]
	local row = vim.api.nvim_buf_get_extmark_by_id(buf, cells_ns, mark, { details = true })[3].end_row
	return (M.opts.display.output_offset and row < vim.fn.getpos("$")[2] - 1) and row + 1 or row
end

local function adjust_output_height(lines)
	local max_height = math.min(#lines, M.opts.display.output_height)
	local output_lines = {}
	for i = 1, max_height do
		output_lines[#output_lines + 1] = { { lines[#lines - max_height + i], "Comment" } }
	end
	if #lines > max_height then
		output_lines[#output_lines + 1] = { { "...[" .. tostring(#lines - max_height) .. " - lines]", "Comment" } }
	end
	return output_lines
end

function M.init(chan, buf)
	M.data[buf] = {}
	M.queue[chan] = M.queue[chan] or {}
	M.is_running[chan] = M.is_running[chan] or false
	M.is_closed[chan] = M.is_closed[chan] or false
end

function M.clear_queue(chan, buf)
	if buf then
		for i, input_info in ipairs(M.queue[chan]) do
			if input_info[1] == buf then
				M.data[buf] = {}
				table.remove(M.queue[chan], i)
			end
		end
	else
		M.queue[chan] = {}
	end
end

function M.add_to_queue(chan, buf, mark)
	for i, input_info in ipairs(M.queue[chan]) do
		if input_info[1] == buf and input_info[2] == mark then
			if M.is_closed[chan] then
				table.remove(M.queue[chan], i)
				if #M.queue[chan] == 0 then
					M.is_closed[chan] = false
					return false
				end
			end
			return not M.is_closed[chan]
		end
	end
	if M.is_closed[chan] then
		return false
	end
	local row = get_output_row(buf, mark)
	M.data[buf][mark] = {}
	table.insert(M.queue[chan], { buf, mark })
	vim.api.nvim_buf_set_extmark(buf, M.ns, row, 0, { id = mark, virt_lines = { { { "[ * ]" } } } })
	return true
end

function M.process(chan, data, name)
	local repl = utils.get_repl(chan)
	local processed_data, is_start, is_end, is_error = format.parse(data, repl)
	if is_start then
		M.is_running[chan] = true
	end
	if M.is_running[chan] then
		if not M.queue[chan] or #M.queue[chan] == 0 then
			vim.notify("Running without any cell being queued")
			return
		end
		local buf, mark = unpack(M.queue[chan][1])
		M.data[buf][mark] = vim.iter({ M.data[buf][mark], processed_data }):flatten():totable()
		if M.opts.display.virt then
			M.display_virt(buf, mark, is_error)
		end
		if M.opts.display.float then
			M.display_float(buf, mark, is_error)
		end
		if is_end or is_error then
			table.remove(M.queue[chan], 1)
			M.is_running[chan] = false
			M.is_closed[chan] = #M.queue[chan] > 0 and is_error or false
			if is_error then
				vim.notify("Cell execution failed, clearing queue", vim.log.levels.WARN)
			end
		end
	end
end

function M.display_virt(buf, mark, fail)
	local row = get_output_row(buf, mark)
	local symbol = fail and { "[ x ]" } or { "[ ✓ ]" }
	local lines = (#M.data[buf][mark] == 0 or fail) and symbol or M.data[buf][mark]
	vim.api.nvim_buf_set_extmark(buf, M.ns, row, 0, { id = mark, virt_lines = adjust_output_height(lines) })
end

function M.display_float(buf, mark, fail)
	local row = get_output_row(buf, mark)
	local lines = M.data[buf][mark]
	if vim.api.nvim_win_is_valid(M.float.win) then
		if buf == buf and mark == mark then
			vim.api.nvim_buf_set_lines(M.float.buf, 0, -1, false, lines)
			vim.api.nvim_win_set_cursor(M.float.win, { vim.fn.line("$", M.float.win), 0 })
			return
		else
			M.clear_float()
		end
	end
	local virt_pad = {}
	for i = 1, math.min(#lines, M.opts.display.output_height) + 2 do
		virt_pad[i] = { { "" } }
	end
	if #lines > 0 then
		vim.api.nvim_buf_set_extmark(buf, M.ns, row, 0, { id = mark, virt_lines = virt_pad })
	end
	M.float.mark = mark
	M.float.buf = vim.api.nvim_create_buf(false, true)
	M.float.win = #lines > 0
			and vim.api.nvim_open_win(M.float.buf, false, {
				relative = "win",
				bufpos = { row, 0 },
				width = vim.o.columns,
				height = math.min(#lines, M.opts.display.output_height),
				border = { "", "─", "", "", "", "─", "", "" },
			})
		or -1
	vim.keymap.set("n", "q", M.clear_float, { buffer = M.float.buf })
	vim.api.nvim_buf_set_lines(M.float.buf, 0, -1, false, lines)
end

function M.clear_float()
	if vim.api.nvim_win_is_valid(M.float.win) then
		vim.api.nvim_win_close(M.float.win, true)
		M.float.win = -1
	end
end

return M
