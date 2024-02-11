return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		vim.keymap.set("n", "<leader>tt", function()
			require("trouble").toggle("workspace_diagnostics")
		end, { silent = true, noremap = true })
	end,
}
