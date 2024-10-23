local M = { enabled = false, ns = vim.api.nvim_create_namespace("Zen") }

local function zen()
	local zen_width = math.floor(vim.o.columns * 0.7)
	local zen_col = math.floor(vim.o.columns * 0.15)
	if not M.enabled then
		local curr_buf = vim.api.nvim_get_current_buf()
		local bg_buf = vim.api.nvim_create_buf(false, true)
		vim.bo[bg_buf].modifiable = false
		vim.bo[bg_buf].buftype = "nofile"
		vim.bo[bg_buf].bufhidden = "wipe"
		local bg_win = vim.api.nvim_open_win(bg_buf, false, {
			relative = "editor",
			width = vim.o.columns,
			height = vim.o.lines,
			col = 1,
			row = 1,
			style = "minimal",
			zindex = 20,
			focusable = false,
		})
		local zen_win = vim.api.nvim_open_win(curr_buf, true, {
			relative = "editor",
			width = zen_width,
			height = vim.o.lines,
			col = zen_col,
			row = 1,
			style = "minimal",
			zindex = 20,
		})
		vim.api.nvim_win_set_hl_ns(zen_win, M.ns)
		vim.api.nvim_set_hl(M.ns, "NormalFloat", { link = "Normal" })
		M.quit_autocmd = vim.api.nvim_create_autocmd("WinClosed", {
			desc = "Zen quit",
			pattern = tostring(zen_win),
			callback = function()
				vim.api.nvim_del_autocmd(M.switch_autocmd)
				vim.api.nvim_win_close(bg_win, true)
				vim.api.nvim_del_autocmd(M.quit_autocmd)
				M.enabled = not M.enabled
			end,
		})
		M.switch_autocmd = vim.api.nvim_create_autocmd("BufWinEnter", {
			desc = "Zen switch",
			nested = true,
			callback = function()
				vim.api.nvim_win_set_hl_ns(zen_win, M.ns)
				local new_win = vim.api.nvim_get_current_win()
				local is_float = vim.api.nvim_win_get_config(new_win).relative ~= ""
				if is_float then
					return
				else
					vim.api.nvim_win_close(zen_win, true)
				end
			end,
		})
		M.enabled = not M.enabled
	else
		vim.notify("You're already zen", vim.log.levels.INFO)
	end
end

vim.keymap.set("n", "<leader>z", zen, { desc = "Zen" })
