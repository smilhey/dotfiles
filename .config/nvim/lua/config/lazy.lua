local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
-- vim.opts.ui.backdrop = false

local opts = {
	performance = {
		rtp = {
			disabled_plugins = {
				"2html",
				"gzip",
				"remote_plugins",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
				"netrw",
				"netrwPlugin",
			},
		},
	},
	ui = {
		border = "single",
		backdrop = 100,
		title = "Lazy.nvim",
	},
}
require("lazy").setup("plugins", opts)
