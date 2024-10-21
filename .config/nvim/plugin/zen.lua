local M = { enabled = false }

local function zen()
	local zen_width = math.floor(vim.o.columns * 0.7)
	local zen_col = math.floor(vim.o.columns * 0.15)
	if not M.enabled then
		local curr_buf = vim.api.nvim_get_current_buf()
		M.bg_buf = vim.api.nvim_create_buf(false, true)
		vim.bo[M.bg_buf].modifiable = false
		vim.bo[M.bg_buf].buftype = "nofile"
		vim.bo[M.bg_buf].bufhidden = "wipe"
		M.bg_win = vim.api.nvim_open_win(M.bg_buf, false, {
			relative = "editor",
			width = vim.o.columns,
			height = vim.o.lines,
			col = 1,
			row = 1,
			style = "minimal",
			zindex = 20,
			focusable = false,
		})
		M.zen_win = vim.api.nvim_open_win(curr_buf, true, {
			relative = "editor",
			width = zen_width,
			height = vim.o.lines,
			col = zen_col,
			row = 1,
			style = "minimal",
			zindex = 20,
		})
		M.autocmd = vim.api.nvim_create_autocmd("WinEnter", {
			desc = "Zen",
			callback = function()
				local new_win = vim.api.nvim_get_current_win()
				local is_float = vim.api.nvim_win_get_config(new_win).relative ~= ""
				if is_float then
					return
				else
					vim.api.nvim_del_autocmd(M.autocmd)
					vim.api.nvim_win_close(M.bg_win, true)
					if vim.api.nvim_win_is_valid(M.zen_win) then
						vim.api.nvim_win_close(M.zen_win, true)
					end
					M.enabled = not M.enabled
				end
			end,
		})
	else
		vim.api.nvim_del_autocmd(M.autocmd)
		vim.api.nvim_win_close(M.bg_win, true)
		vim.api.nvim_win_close(M.zen_win, true)
	end
	M.enabled = not M.enabled
end

vim.keymap.set("n", "<leader>z", zen, { desc = "Zen" })
