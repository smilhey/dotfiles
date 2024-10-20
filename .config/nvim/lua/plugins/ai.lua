return {
	-- {
	-- 	"zbirenbaum/copilot-cmp",
	-- 	config = function()
	-- 		require("copilot_cmp").setup()
	-- 	end,
	-- },
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		config = function()
			require("copilot").setup({
				-- suggestion = { enabled = true, keymap = { accept = "<M-;>" } },
				suggestion = { enabled = false },
				panel = { enabled = false },
				filetypes = {
					markdown = true,
				},
			})
		end,
	},
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("codecompanion").setup({
				strategies = {
					chat = {
						adapter = "copilot",
						keymaps = {
							close = {
								modes = {
									n = "q",
									i = "<C-q>",
								},
								index = 3,
								callback = "keymaps.close",
								description = "Close Chat",
							},
							stop = {
								modes = {
									n = "C-q",
								},
								index = 4,
								callback = "keymaps.stop",
								description = "Stop Request",
							},
						},
					},
					inline = {
						adapter = "copilot",
					},
					agent = {
						adapter = "copilot",
					},
				},
				display = {
					action_palette = {
						width = 95,
						height = 10,
					},
					chat = {
						window = {
							layout = "buffer", -- float|vertical|horizontal|buffer
							border = "single",
							height = 0.8,
							width = 0.45,
							relative = "editor",
							-- layout = "split",
							-- relative = "editor",
							-- width = 0.45,
							-- height = 0.85,
							-- row = 1,
							-- col = 90,
							-- zindex = 50,
						},
					},
				},
			})
			vim.keymap.set(
				{ "n", "v" },
				"<leader>a",
				"<cmd>CodeCompanionChat Toggle<cr>",
				{ noremap = true, silent = true }
			)
		end,
	},
}
