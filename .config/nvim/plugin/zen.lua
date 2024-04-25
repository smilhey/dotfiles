-- Function to create two vertical splits on each side of the current window with scratch buffers in them
local zen_panes = {}

local function zen()
	if not vim.tbl_isempty(zen_panes) then
		for _, pane in ipairs(zen_panes) do
			vim.api.nvim_win_close(pane, true)
		end
		zen_panes = {}
		return
	end
	local current_window = vim.api.nvim_get_current_win()
	local scratch_buffer = vim.api.nvim_create_buf(false, true)
	vim.bo[scratch_buffer].filetype = "Zen"
	local left_pane = vim.api.nvim_open_win(scratch_buffer, true, {
		split = "left",
	})
	vim.api.nvim_set_current_win(current_window)
	local right_pane = vim.api.nvim_open_win(scratch_buffer, true, {
		split = "right",
	})
	vim.api.nvim_set_current_win(current_window)
	vim.wo[left_pane].number = false
	vim.wo[right_pane].number = false
	vim.wo[left_pane].relativenumber = false
	vim.wo[right_pane].relativenumber = false
	vim.wo[left_pane].fillchars = "eob: "
	vim.wo[right_pane].fillchars = "eob: "
	vim.api.nvim_win_set_width(left_pane, 30)
	vim.api.nvim_win_set_width(right_pane, 30)
	zen_panes = { left_pane, right_pane }
end

vim.api.nvim_create_user_command("Zen", zen, {})
vim.keymap.set("n", "<leader>z", zen, {})
