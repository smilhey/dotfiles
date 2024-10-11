return {
	"OXY2DEV/markview.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("markview").setup({
			modes = { "n", "no", "c", "v", "i", "x" },
			hybrid_modes = { "i", "n" },
			-- callbacks = {
			-- 	on_enable = function(_, win)
			-- 		vim.wo[win].conceallevel = 2
			-- 	end,
			-- },
			code_blocks = {
				style = "simple",
			},
		})
	end,
}
