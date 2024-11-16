local utils = require("repl.utils")

local cells = {
	ns = vim.api.nvim_create_namespace("cells"),
	o_ns = vim.api.nvim_create_namespace("output"),
	augroup = vim.api.nvim_create_augroup("cells", {}),
	display = { virt = true, float = true, output_height = 8, output_offset = true, highlight = true },
	current = nil,
}
cells.__index = cells
cells.__eq = function(c1, c2)
	return c1.mark == c2.mark and c1.buf == c2.buf
end
cells.__tostring = function(cell)
	return vim.inspect({ mark = cell.mark, buf = cell.buf })
end

function cells.create(buf, info)
	local mark = type(info) == "table"
			and vim.api.nvim_buf_set_extmark(buf, cells.ns, info[1], info[2], { end_row = info[3], end_col = info[4] })
		or info
	local cell = setmetatable({
		buf = buf,
		mark = mark,
		float = { win = -1, buf = -1 },
	}, cells)
	return cell
end

function cells:clear()
	self:clear_float()
	vim.api.nvim_buf_del_extmark(self.buf, cells.ns, self.mark)
	vim.api.nvim_buf_del_extmark(self.buf, cells.o_ns, self.mark)
end

function cells.clear_range(buf, start_row, start_col, end_row, end_col)
	local mark_list = utils.get_range_marks(buf, cells.ns, start_row, start_col, end_row, end_col)
	local cell_list = vim.tbl_map(function(mark)
		return cells.create(buf, mark)
	end, mark_list)
	for _, c in ipairs(cell_list) do
		c:clear()
	end
end

function cells.clear_all(buf)
	vim.api.nvim_buf_clear_namespace(buf, cells.ns, 0, -1)
	vim.api.nvim_buf_clear_namespace(buf, cells.o_ns, 0, -1)
end

function cells:send(chan, receive)
	local mark_info = vim.api.nvim_buf_get_extmark_by_id(self.buf, cells.ns, self.mark, { details = true })
	if not mark_info or vim.tbl_isempty(mark_info) then
		vim.notify("Cell got cleared while handler was still serving", vim.log.levels.ERROR)
		return
	end
	local start_row, start_col, end_row, end_col =
		mark_info[1], mark_info[2], mark_info[3].end_row, mark_info[3].end_col
	local selection = vim.api.nvim_buf_get_text(self.buf, start_row, start_col, end_row, end_col, {})
	if receive then
		utils.send_selection(chan, selection, self.buf, self.mark)
	else
		utils.send_selection(chan, selection)
	end
end

local function get_output_row(buf, mark, output_offset)
	local row = vim.api.nvim_buf_get_extmark_by_id(buf, cells.ns, mark, { details = true })[3].end_row
	return (output_offset and row < vim.fn.getpos("$")[2] - 1) and row + 1 or row
end

local function adjust_output_height(lines, output_height)
	local max_height = math.min(#lines, output_height)
	local output_lines = {}
	for i = 1, max_height do
		output_lines[#output_lines + 1] = { { lines[#lines - max_height + i], "Comment" } }
	end
	if #lines > max_height then
		output_lines[#output_lines + 1] = { { "...[" .. tostring(#lines - max_height) .. " - lines]", "Comment" } }
	end
	return output_lines
end

function cells:display_virt(success)
	local row = get_output_row(self.buf, self.mark)
	local symbol = success and { "[ ✓ ]" } or { "[ x ]" }
	local lines = (#self.output == 0 or not success) and symbol or self.output
	vim.api.nvim_buf_set_extmark(
		self.buf,
		self.o_ns,
		row,
		0,
		{ id = self.mark, virt_lines = adjust_output_height(lines, cells.display.output_height) }
	)
end

function cells:init_float()
	if not vim.api.nvim_win_is_valid(self.float.win) then
		local row = get_output_row(self.buf, self.mark)
		self.float.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[self.float.buf].bufhidden = "wipe"
		self.float.win = vim.api.nvim_open_win(self.float.buf, false, {
			relative = "win",
			bufpos = { row, 0 },
			width = vim.o.columns,
			height = 1,
			border = { "", "─", "", "", "", "─", "", "" },
		}) or -1
		vim.keymap.set("n", "q", function()
			self:clear_float()
		end, { buffer = self.float.buf })
	end
end

function cells:update_float()
	if vim.api.nvim_win_is_valid(self.float.win) then
		if #self.output == 0 then
			vim.api.nvim_win_close(self.float.win, true)
			return
		end
		local row = get_output_row(self.buf, self.mark)
		local virt_pad = {}
		for i = 1, math.min(#self.output, cells.display.output_height) + 2 do
			virt_pad[i] = { { "" } }
		end
		vim.api.nvim_buf_set_extmark(self.buf, self.o_ns, row, 0, { id = self.mark, virt_lines = virt_pad })
		vim.api.nvim_buf_set_lines(self.float.buf, 0, -1, false, self.output)
		vim.api.nvim_win_set_config(self.float.win, { height = math.min(#self.output, self.display.output_height) })
		vim.api.nvim_win_set_cursor(self.float.win, { vim.fn.line("$", self.float.win), 0 })
	end
end

function cells:display_float()
	self:init_float()
	self:update_float()
end

function cells:display_output(success)
	if cells.display.virt then
		self:display_virt(success)
	end
	if cells.display.float then
		self:update_float()
	end
end

function cells:clear_float()
	if vim.api.nvim_win_is_valid(self.float.win) then
		vim.api.nvim_win_close(self.float.win, true)
		if self.display.virt then
			self:display_virt(true)
		end
	end
end

function cells:highlight(hl_group)
	local mark_info = vim.api.nvim_buf_get_extmark_by_id(self.buf, cells.ns, self.mark, { details = true })
	if not vim.tbl_isempty(mark_info) then
		vim.api.nvim_buf_set_extmark(self.buf, cells.ns, mark_info[1], mark_info[2], {
			id = self.mark,
			end_row = mark_info[3].end_row,
			end_col = mark_info[3].end_col,
			hl_group = hl_group,
		})
	end
end

function cells.disable_hl(buf)
	local autocmd = vim.api.nvim_get_autocmds({ group = cells.augroup, buffer = buf })[1].id
	if autocmd then
		vim.api.nvim_del_autocmd(autocmd)
	end
end

return cells
