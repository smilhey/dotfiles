return {
	event = "VeryLazy",
	"jackMort/ChatGPT.nvim",
	config = function()
		local home = vim.fn.expand("$HOME")
		require("chatgpt").setup({
			-- api_key_cmd = "gpg --decrypt " .. home .. "/notes/api_key.gpg",
			api_key_cmd = "cat " .. home .. "/notes/key",
			openai_params = {
				model = "gpt-4-turbo",
				frequency_penalty = 0,
				presence_penalty = 0,
				max_tokens = 4095,
				temperature = 0.2,
				top_p = 0.1,
				n = 1,
			},
		})
	end,
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"folke/trouble.nvim",
		"nvim-telescope/telescope.nvim",
	},
}
