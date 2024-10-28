local format = require("repl.format")
local utils = require("repl.utils")

local M = {
	data = {},
	queue = {},
	enabled = {},
	is_running = {},
	opts = { display = { virt = true, float = false, output_height = 8, output_offset = false } },
	float = { win = -1, buf = -1 },
	ns = vim.api.nvim_create_namespace("output"),
}

function M.add_to_queue(chan, buf, mark)
	if
		vim.tbl_contains(M.queue[chan], function(v)
			return vim.deep_equal(v, { buf, mark })
		end, { predicate = true })
	then
		return
	end
	local cells_ns = vim.api.nvim_get_namespaces()["cells"]
	local row = vim.api.nvim_buf_get_extmark_by_id(buf, cells_ns, mark, { details = true })[3].end_row
	row = (M.opts.display.output_offset and row < vim.fn.getpos("$")[2] - 1) and row + 1 or row
	M.data[buf][mark] = {}
	M.queue[chan][#M.queue[chan] + 1] = { buf, mark }
	vim.api.nvim_buf_set_extmark(buf, M.ns, row, 0, { id = mark, virt_lines = { { { "[ * ]" } } } })
end

function M.is_end(data)
	for i, str in ipairs(data) do
		if str:find("KeyboardInterrupt") then
			return i
		end
		if str:find("[MARK END]", 1, true) then
			return i
		end
	end
	return 0
end

function M.is_start(data)
	for _, str in ipairs(data) do
		if str:find("[MARK START]", 1, true) then
			return true
		end
	end
	return false
end

function M.process(chan, data, name)
	local repl = utils.get_repl(chan)
	if M.is_start(data) then
		M.is_running[chan] = true
	end
	if M.is_running[chan] then
		local buf, mark = unpack(M.queue[chan][1])
		local end_signal_index = M.is_end(data)
		if end_signal_index > 0 then
			table.remove(M.queue[chan], 1)
			if end_signal_index > 1 then
				data = vim.iter(data):take(end_signal_index - 1):totable()
				M.data[buf][mark] = vim.iter({ M.data[buf][mark], data }):flatten():totable()
			end
			if M.opts.display.virt then
				M.display_virt(repl, buf, mark)
			end
			if M.opts.display.float then
				M.display_float(repl, buf, mark)
			end
			M.is_running[chan] = false
			P(buf .. " - " .. mark)
			P(data[buf][mark])
		else
			M.data[buf][mark] = vim.iter({ M.data[buf][mark], data }):flatten():totable()
		end
	end
end

function M.display_virt(repl, buf, mark)
	local cells_ns = vim.api.nvim_get_namespaces()["cells"]
	local row = vim.api.nvim_buf_get_extmark_by_id(buf, cells_ns, mark, { details = true })[3].end_row
	row = (M.opts.display.output_offset and row < vim.fn.getpos("$")[2] - 1) and row + 1 or row
	local lines = format.output[repl](M.data[buf][mark])
	lines = #lines == 0 and { "[ ✓ ]" } or lines
	local len = M.opts.display.output_height > #lines and #lines or M.opts.display.output_height
	local virt_lines = {}
	for i = 1, len do
		virt_lines[#virt_lines + 1] = { { lines[i], "Comment" } }
	end
	if M.opts.display.output_height < #lines then
		virt_lines[#virt_lines + 1] =
			{ { "...[" .. tostring(#lines - M.opts.display.output_height) .. " - lines]", "Comment" } }
	end
	vim.api.nvim_buf_set_extmark(buf, M.ns, row, 0, { id = mark, virt_lines = virt_lines })
end

function M.clear_virt(buf, mark)
	vim.api.nvim_buf_del_extmark(buf, M.ns, mark)
end

function M.display_float(repl, buf, mark)
	local cells_ns = vim.api.nvim_get_namespaces()["cells"]
	local row = vim.api.nvim_buf_get_extmark_by_id(buf, cells_ns, mark, { details = true })[3].end_row
	row = M.opts.display.output_offset and row + 1 or row
	local lines = format.output[repl](M.data[buf][mark])
	local len = M.opts.display.output_height > #lines and #lines or M.opts.display.output_height
	local virt_pad = {}
	for i = 1, len + 2 do
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
				height = #lines < M.opts.display.output_height and #lines or M.opts.display.output_height,
				border = { "", "─", "", "", "", "─", "", "" },
			})
		or -1
	vim.keymap.set("n", "q", function()
		if M.opts.display.virt then
			M.display_virt(repl, buf, mark)
		end
		vim.api.nvim_win_close(M.float.win, true)
	end, { buffer = M.float.buf })
	vim.api.nvim_buf_set_lines(M.float.buf, 0, -1, false, lines)
end

function M.clear_float()
	if vim.api.nvim_win_is_valid(M.float.win) then
		vim.api.nvim_win_close(M.float.win, true)
		M.float.win = -1
	end
end

return M
