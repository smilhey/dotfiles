local format = require("repl.format")
local utils = require("repl.utils")

local handlers = { augroup = vim.api.nvim_create_augroup("repl-handler", { clear = true }) }
handlers.__index = handlers

function handlers.init(chan, receive)
	local h = setmetatable({
		chan = chan,
		repl = utils.get_repl(chan),
		cells = {},
		queue = {},
		processing = false,
		active = false,
		receive = receive,
		cur_cell = nil,
	}, handlers)
	return h
end

function handlers:attach(buf)
	self.cells[buf] = {}
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		group = handlers.augroup,
		buffer = buf,
		desc = "highlight cell under cursor and show output in float",
		callback = function()
			local cell = self:get_cursor_cell()
			if self == self.cur_cel then
				return
			end
			if cell then
				if cell.display.highlight then
					cell:highlight("TabLineSel")
				end
				self.cur_cell = cell
			elseif self.cur_cell then
				self.cur_cell:highlight()
				self.cur_cell = nil
			end
		end,
	})
end

function handlers:clear_queue(buf)
	for i = #self.queue, 1, -1 do
		local cell = self.queue[i]
		if not buf or cell.buf == buf then
			cell:clear()
			table.remove(self.queue, i)
		end
	end
	self.is_processing = false
end

function handlers:add_to_queue(cell)
	table.insert(self.queue, cell)
	if self.receive then
		cell.state = "pending"
		cell.time = ""
		cell:display_virt()
	end
end

function handlers:process_cell(cell)
	cell:send(self.chan, self.receive)
	self.cells[cell.buf][cell.mark] = cell
	if self:get_cursor_cell() == cell then
		cell:highlight("TabLineSel")
		self.cur_cell = cell
	end
end

function handlers:process_queue()
	if #self.queue == 0 then
		self.processing = false
		return
	end
	if self.processing then
		return
	end
	self:process_cell(self.queue[1])
	self.processing = self.receive
	if not self.receive then
		table.remove(self.queue, 1)
	end
end

function handlers:on_output(data)
	local processed_data, is_start, is_end, is_error = format.parse(data, self.repl)
	if is_start then
		self.active = true
		self.start_time = vim.uv.hrtime()
	end
	if not self.active then
		return
	end
	if #self.queue == 0 then
		vim.notify("Unexpected output with no active cell", vim.log.levels.WARN)
		return
	end
	local cell = self.queue[1]
	cell.output = vim.iter({ cell.output, processed_data }):flatten():totable()
	cell.time = os.date("!%M:%S", (vim.uv.hrtime() - self.start_time) / 1e9)
	cell.state = "pending"
	if is_error then
		cell.state = "fail"
		self.active = false
		self.processing = false
		table.remove(self.queue, 1)
		vim.notify("Cell execution failed, clearing queue", vim.log.levels.WARN)
		self:clear_queue()
	elseif is_end then
		cell.state = "done"
		self.active = false
		self.processing = false
		table.remove(self.queue, 1)
		self:process_queue()
	end
	cell:display_virt()
end

function handlers:interrupt()
	utils.send_selection(self.chan, { string.char(0x03) })
end

function handlers:get_cursor_cell()
	local cells_ns = vim.api.nvim_get_namespaces()["cells"]
	local buf = vim.api.nvim_get_current_buf()
	local mark = utils.get_cursor_mark(cells_ns)
	local cell = self.cells[buf][mark]
	return cell
end

return handlers
