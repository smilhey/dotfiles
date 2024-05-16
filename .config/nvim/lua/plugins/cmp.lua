return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"onsails/lspkind-nvim",
	},
	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")

		local cmp_select = { behavior = cmp.SelectBehavior.Select }
		local cmp_mappings = cmp.mapping.preset.insert({
			["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
			["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
			["<C-y>"] = cmp.mapping.confirm({ select = true }),
			["<C-Space>"] = cmp.mapping.complete(),
		})
		cmp_mappings["<Tab>"] = nil
		cmp_mappings["<S-Tab>"] = nil
		vim.keymap.set({ "i", "s" }, "<Tab>", function()
			if vim.snippet.active({ direction = 1 }) then
				return "<cmd>lua vim.snippet.jump(1)<cr>"
			else
				return "<Tab>"
			end
		end, { expr = true, desc = "Jump to next snippet placeholder" })
		vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
			if vim.snippet.active({ direction = -1 }) then
				return "<cmd>lua vim.snippet.jump(-1)<cr>"
			else
				return "<S-Tab>"
			end
		end, { expr = true, desc = "Jump to previous snippet placeholder" })

		cmp.setup({
			snippet = {
				expand = function(args)
					vim.snippet.expand(args.body)
				end,
			},
			mapping = cmp_mappings,
			window = {
				completion = { border = "single" },
				documentation = { border = "single" },
			},
			formatting = {
				format = lspkind.cmp_format({
					with_text = true,
					menu = {
						otter = "[LSPo]",
						path = "[path]",
						copilot = "",
						buffer = "[buf]",
						nvim_lsp = "[LSP]",
					},
				}),
			},
			sources = {
				{ name = "otter" },
				{ name = "nvim_lsp" },
				{ name = "copilot" },
				{ name = "path" },
				{ name = "buffer", keyword_length = 3 },
			},
		})
		vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { link = "String" })
	end,
}
