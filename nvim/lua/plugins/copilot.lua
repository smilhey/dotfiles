return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	suggestion = { enabled = false },
	panel = { enabled = false },
	config = function()
		require("copilot").setup({})
	end,
	dependencies = {
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup()
		end,
	},
}
