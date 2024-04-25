-- Launch a float terminal UI with the given command
local function launch(tui)
	local buffer = vim.api.nvim_create_buf(false, true)

	local screen_width = vim.api.nvim_get_option_value("columns", {})
	local screen_height = vim.api.nvim_get_option_value("lines", {})
	local float_width = 100
	local float_height = 30
	local row = math.floor((screen_height - float_height) / 2)
	local col = math.floor((screen_width - float_width) / 2)

	vim.api.nvim_open_win(buffer, true, {
		relative = "editor",
		width = float_width,
		height = float_height,
		row = row,
		col = col,
		style = "minimal",
		border = "single",
	})

	vim.cmd("term " .. tui)
	vim.schedule(function()
		vim.cmd("startinsert")
	end)
end

vim.keymap.set("n", "<leader>ui", function()
	vim.ui.input("Launch TUI: ", function(tui)
		launch(tui)
	end)
end, {})
