return {
	"jmbuhr/otter.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "neovim/nvim-lspconfig" },
	config = function()
		vim.api.nvim_create_autocmd({ "BufEnter" }, {
			pattern = { "*.md", "*.ipynb" },
			callback = function()
				vim.cmd("lua require'otter'.activate()")
			end,
		})
	end,
}
