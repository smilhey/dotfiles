return {
	{
		"nvim-neorg/neorg",
		dependencies = { "vhyrro/luarocks.nvim" },
		ft = "norg",
		config = function()
			require("neorg").setup({
				load = {
					["core.defaults"] = {}, -- Loads default behaviour
					["core.completion"] = { config = { engine = "nvim-cmp" } }, -- Enables completion
					["core.concealer"] = {
						config = {
							folds = false,
							-- icon_preset = "varied",
							icons = {
								code_block = {
									spell_check = false,
								},
							},
						},
					},
					["core.dirman"] = { -- Manages Neorg workspaces
						config = {
							workspaces = {
								notes = "~/notes",
							},
						},
					},
					["core.integrations.otter"] = {},
					["core.integrations.treesitter"] = {},
					["core.latex.renderer"] = {},
					["core.integrations.image"] = { config = { render_on_enter = true } },
				},
			})
		end,
	},
}
