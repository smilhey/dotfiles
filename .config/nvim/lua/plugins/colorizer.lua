return {
	"NvChad/nvim-colorizer.lua",
	config = function()
		vim.opt.termguicolors = true
		require("colorizer").setup({
			-- 	mode = "virtualtext", -- Set the display mode.
			--              user_default_options = {
			-- 	virtualtext = "██",
			-- },
		})
	end,
}
