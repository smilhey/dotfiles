--- @class menu
--- @field actions table
--- @field format function
--- @field get_items function
--- @field opts table
--- @field string_items table
--- @field buf number
--- @field namespace number
--- @field legend table
--- @field legend_size number
--- @field win number
local Menu = {}

--- Constructor for the Menu class.
--- @param get_items function returns the items to be displayed in the menu
--- @param format function formats the items for in the menu buffer
--- @param actions table actions that can be performed on the items
--- @param opts table options for the menu : { legend = {include = boolean, style = horizontal|vertical}, resize = { horizontal = boolean, vertical = boolean }, win_opts = table }
--- @return menu
function Menu:new(get_items, format, actions, opts)
	local menu = {
		actions = actions,
		format = format,
		get_items = get_items,
		opts = opts,
	}
	menu.string_items = vim.tbl_map(function(item)
		return format(item)
	end, get_items())
	menu.buf = Menu.create_buffer()
	menu.namespace = vim.api.nvim_create_namespace("menu")

	menu.legend = {}
	menu.legend_size = 0
	if opts.legend.include then
		menu.legend = opts.legend.style == "vertical" and { {} } or {}
		menu.legend_size = opts.legend.style == "vertical" and -1 or 0
		for key, action in pairs(actions) do
			if opts.legend.style == "horizontal" then
				menu.legend_size = math.max(menu.legend_size, #key + #action.desc + 2)
				menu.legend[#menu.legend + 1] = { { key .. ": ", "Constant" }, { action.desc, "Normal" } }
			elseif opts.legend.style == "vertical" then
				menu.legend_size = menu.legend_size + #key + #action.desc + 3
				table.insert(menu.legend[1], { key .. ": ", "Constant" })
				table.insert(menu.legend[1], { action.desc .. " ", "Normal" })
			end
		end
	end

	self.__index = self

	return setmetatable(menu, self)
end

function Menu.create_buffer()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false
	vim.keymap.set("n", "q", "<cmd>close!<CR>", { nowait = true, noremap = true, silent = true, buffer = buf })
	return buf
end

function Menu:render_buffer()
	vim.bo[self.buf].modifiable = true
	vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, self.string_items)
	vim.bo[self.buf].modifiable = false
	if not vim.tbl_isempty(self.legend) then
		vim.api.nvim_buf_set_extmark(self.buf, self.namespace, #self.string_items - 1, 0, { virt_lines = self.legend })
	end
end

function Menu:create_window()
	local default_win_opts = {
		relative = "editor",
		width = math.max(unpack(vim.tbl_map(function(str)
			return #str
		end, self.string_items))),
		height = #self.string_items + #self.legend,
		focusable = true,
		border = "single",
		title = "Menu",
		style = "minimal",
	}
	default_win_opts.col = math.ceil((vim.o.columns - default_win_opts.width) / 2)
	default_win_opts.row = math.ceil((vim.o.lines - default_win_opts.height) / 2)
	default_win_opts.width = math.max(default_win_opts.width, self.legend_size)
	default_win_opts = vim.tbl_deep_extend("force", default_win_opts, self.opts.win_opts)
	self.win = vim.api.nvim_open_win(self.buf, true, default_win_opts)
	vim.wo[self.win].winfixbuf = true
end

function Menu:resize_window()
	if self.opts.resize.horizontal then
		vim.api.nvim_win_set_height(self.win, #self.string_items + #self.legend)
	end
	if self.opts.resize.vertical then
		local max_string_items = math.max(unpack(vim.tbl_map(function(str)
			return #str
		end, self.string_items)))
		vim.api.nvim_win_set_width(self.win, math.max(max_string_items, self.legend_size))
	end
end

function Menu:set_keymaps()
	local on_key = function(a)
		local current_item = self.get_items()[vim.api.nvim_win_get_cursor(0)[1]]
		if a.close then
			vim.api.nvim_win_close(0, true)
		end
		a.fn(current_item)
		if a.update then
			self.string_items = vim.tbl_map(function(item)
				return self.format(item)
			end, self.get_items())
			if vim.tbl_isempty(self.string_items) then
				vim.api.nvim_win_close(0, true)
				vim.notify("No more items to display in the menu", vim.log.levels.WARN)
				return
			end
			self:render_buffer()
			self:resize_window()
		end
	end
	for key, action in pairs(self.actions) do
		vim.keymap.set("n", key, function()
			on_key(action)
		end, { nowait = true, noremap = true, silent = true, buffer = self.buf })
	end
end

function Menu:__call()
	if vim.tbl_isempty(self.string_items) then
		vim.notify("No items to display in the menu", vim.log.levels.WARN)
		return
	end
	self:set_keymaps()
	self:render_buffer()
	self:create_window()
end

return Menu
