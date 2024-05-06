-- Function to create two vertical splits on each side of the current window with scratch buffers in them
local state = {
	opt = {
		tabline = vim.opt.tabline,
		laststatus = vim.opt.laststatus,
		showtabline = vim.opt.showtabline,
		number = vim.opt.number,
		relativenumber = vim.opt.relativenumber,
		signcolumn = vim.opt.signcolumn,
		fillchars = vim.opt.fillchars,
	},
	opt_local = { winbar = vim.opt_local.winbar },
	panes = {},
	on = false,
}

local function zen()
	if not vim.tbl_isempty(state.panes) then
		for _, pane in ipairs(state.panes) do
			vim.api.nvim_win_close(pane, true)
		end
		state.panes = {}
		return
	end
	local current_window = vim.api.nvim_get_current_win()
	local scratch_buffer = vim.api.nvim_create_buf(false, true)
	vim.bo[scratch_buffer].filetype = "Zen"
	local left_pane = vim.api.nvim_open_win(scratch_buffer, true, {
		split = "left",
		style = "minimal",
	})
	vim.api.nvim_set_current_win(current_window)
	local right_pane = vim.api.nvim_open_win(scratch_buffer, true, {
		split = "right",
		style = "minimal",
	})
	vim.api.nvim_set_current_win(current_window)
	vim.api.nvim_win_set_width(left_pane, 30)
	vim.api.nvim_win_set_width(right_pane, 30)
	state.panes = { left_pane, right_pane }
end

vim.api.nvim_create_user_command("Zen", zen, {})
vim.keymap.set("n", "<leader>z", function()
	zen()
	if state.on then
		for opt, value in pairs(state.opt) do
			vim.opt[opt] = value
		end
		for opt, value in pairs(state.opt_local) do
			vim.opt_local[opt] = value
		end
	else
		vim.opt.signcolumn = "no"
		vim.opt.number = false
		vim.opt.relativenumber = false
		vim.opt.tabline = ""
		vim.opt.laststatus = 0
		vim.opt.showtabline = 0
		vim.opt_local.winbar = ""
		vim.opt.fillchars = "eob: ,vert: "
	end
	state.on = not state.on
end, { desc = "Zen" })
