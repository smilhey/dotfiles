return {
	{
		"sam4llis/nvim-tundra",
		-- config = function()
		-- 	vim.g.tundra_biome = "arctic" -- 'arctic' or 'jungle'
		-- 	vim.opt.background = "dark"
		-- 	vim.api.nvim_set_hl(0, "Cursor", { link = "Substitute" })
		-- 	vim.api.nvim_set_hl(0, "PmenuKindSel", { link = "Cursor" })
		-- 	vim.cmd("colorscheme tundra")
		-- end,
	},
	{
		"Shatur/neovim-ayu",
		config = function()
			vim.cmd("colorscheme ayu")
		end,
	},
}
