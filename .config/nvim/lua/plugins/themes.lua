return {
	"sam4llis/nvim-tundra",
	config = function()
		vim.g.tundra_biome = "arctic" -- 'arctic' or 'jungle'
		vim.opt.background = "dark"
		vim.cmd("colorscheme tundra")
		-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		-- vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
		vim.api.nvim_set_hl(0, "Cursor", { link = "Substitute" })
		vim.api.nvim_set_hl(0, "PmenuKindSel", { link = "Cursor" })
		vim.opt.guicursor = "a:block-blinkon0,i:Cursor,r-cr-o:hor20,c:Cursor,ci:Cursor,cr:Cursor"
	end,
}
