return {
	"mbbill/undotree",
	config = function()
		vim.keymap.set("n", "<leader>un", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })
	end,
}
