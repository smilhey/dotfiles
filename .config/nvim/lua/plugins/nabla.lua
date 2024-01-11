return {
	"jbyuki/nabla.nvim",
	config = function()
		vim.keymap.set(
			"n",
			"<leader>ll",
			"<cmd>lua require('nabla').toggle_virt()<CR>",
			{ noremap = true, silent = true }
		)
	end,
}
