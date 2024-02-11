vim.opt_local.colorcolumn = "81"
vim.cmd("hi ColorColumn ctermbg=lightgrey guibg=#ebdbb2")
vim.opt_local.textwidth = 80
vim.opt_local.formatoptions = "tjaw"
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us,fr"

vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*.norg",
	group = vim.api.nvim_create_augroup("norg", { clear = true }),
	callback = function()
		vim.cmd('execute "normal! gggwG "')
	end,
})
