return {
	{
		"nvim-neorg/neorg",
		dependencies = { "luarocks.nvim" },
		ft = "norg",
		config = function()
			vim.opt.conceallevel = 2
			require("neorg").setup({
				load = {
					["core.defaults"] = {}, -- Loads default behaviour
					["core.completion"] = { config = { engine = "nvim-cmp" } }, -- Enables completion
					["core.concealer"] = {
						config = {
							folds = false,
							icon_preset = "varied",
							icons = {
								code_block = {
									spell_check = false,
									width = "content",
									padding = { left = 10, right = 10 },
								},
							},
						},
					}, -- Adds pretty icons to your documents
					["core.dirman"] = { -- Manages Neorg workspaces
						config = {
							workspaces = {
								notes = "~/notes",
							},
						},
					},
				},
			})
		end,
	},
}
