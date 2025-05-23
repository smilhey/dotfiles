-- Launch a general purpose float
local function open_float(cmd)
	local buffer = vim.api.nvim_create_buf(false, true)
	local v_scale = 0.7
	local h_scale = 0.7
	local win = vim.api.nvim_open_win(buffer, true, {
		relative = "editor",
		width = math.floor(v_scale * vim.o.columns),
		height = math.floor(h_scale * vim.o.lines),
		row = math.floor(vim.o.lines * (1 - v_scale) / 2),
		col = math.floor(vim.o.columns * (1 - h_scale) / 2),
		style = "minimal",
		border = "single",
	})
	local ok, result = pcall(vim.cmd, cmd)
	if not ok or vim.api.nvim_get_current_win() ~= win then
		vim.api.nvim_win_close(win, true)
	end
end

vim.keymap.set("n", "<leader>of", function()
	vim.ui.input({ prompt = "Open Float", completion = "cmdline" }, open_float)
end, { desc = "Prompt to open a float with a cmd" })
