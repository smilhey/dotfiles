return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			suggestion = { enabled = true, keymap = { accept = "<M-;>" } },
			panel = { enabled = false },
			filetypes = {
				markdown = true,
			},
		})
	end,
	dependencies = {
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup()
		end,
	},
}
