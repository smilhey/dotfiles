return {
	"NvChad/nvim-colorizer.lua",
	config = function()
		vim.opt.termguicolors = true
		require("colorizer").setup({
			user_default_options = {
				hsl_fn = true,
			},
		})
	end,
}
