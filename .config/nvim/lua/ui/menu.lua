--- Create a window with items and actions related to them.
--- @param items table: The items to be displayed in the menu.
--- @param tostring function: A function to convert an item to a string.
--- @param actions table: A table of actions to be performed with key being the
--- keymap. Each action is a table with a 'desc' and a 'fn' field.
--- @param opts table: A table of options { desc = true if desc is displayed, win_opts = table }
local function win_menu(items, tostring, actions, opts)
	local string_items = vim.tbl_map(function(item)
		return tostring(item)
	end, items)

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.keymap.set("n", "q", "<cmd>close!<CR>", { nowait = true, noremap = true, silent = true, buffer = buf })

	local legend = {}
	local legend_size = 0
	for key, action in pairs(actions) do
		legend_size = math.max(legend_size, #action.desc + #action.desc + 2)
		legend[#legend + 1] = { { key .. ": ", "Constant" }, { action.desc, "Normal" } }
		vim.keymap.set("n", key, function()
			local current_item = items[vim.api.nvim_win_get_cursor(0)[1]]
			if action.close then
				vim.api.nvim_win_close(0, true)
			end
			action.fn(current_item)
		end, { nowait = true, noremap = true, silent = true, buffer = buf })
	end

	local default_win_opts = {
		relative = "editor",
		width = math.max(
			unpack(vim.tbl_map(function(str)
				return #str
			end, string_items)),
			legend_size
		),
		height = #items + vim.tbl_count(actions),
		focusable = true,
		border = "single",
		title = "Menu",
		style = "minimal",
	}
	default_win_opts.width = default_win_opts.width > 10 and default_win_opts.width or 10
	default_win_opts.col = math.ceil((vim.o.columns - default_win_opts.width) / 2)
	default_win_opts.row = math.ceil((vim.o.lines - default_win_opts.height) / 2)
	default_win_opts = vim.tbl_deep_extend("force", default_win_opts, opts.win_opts)
	local win = vim.api.nvim_open_win(buf, true, default_win_opts)
	vim.wo[win].winfixbuf = true

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, string_items)
	local namespace = vim.api.nvim_create_namespace("menu")
	if opts.desc then
		vim.api.nvim_buf_set_extmark(buf, namespace, #items - 1, 0, { virt_lines = legend })
	end
	vim.bo[buf].modifiable = false
end

return win_menu
