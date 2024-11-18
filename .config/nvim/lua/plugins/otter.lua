return {
	"jmbuhr/otter.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = {},
	config = function()
		vim.api.nvim_create_autocmd({ "BufEnter" }, {
			pattern = { "*.md", "*.ipynb" },
			callback = function()
				require("otter").activate(nil, false, true, nil)
			end,
		})
	end,
}
