return {
	"sam4llis/nvim-tundra",
	config = function()
		vim.g.tundra_biome = "arctic" -- 'arctic' or 'jungle'
		vim.opt.background = "dark"
		vim.cmd("colorscheme tundra")
		vim.api.nvim_set_hl(0, "Cursor", { link = "Substitute" })
		vim.api.nvim_set_hl(0, "PmenuKindSel", { link = "Cursor" })
	end,
}
