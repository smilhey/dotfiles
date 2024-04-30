return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"folke/neodev.nvim",
		{
			"williamboman/mason.nvim",
			build = function()
				pcall(vim.cmd, "MasonUpdate")
			end,
			config = function()
				require("mason").setup({
					ui = {
						icons = {
							package_installed = "✓",
							package_pending = "➜",
							package_uninstalled = "✗",
						},
						border = "single",
						height = 0.8,
					},
				})
			end,
		},
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"onsails/lspkind-nvim",
	},
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "LSP actions",
			callback = function(client, bufnr)
				vim.keymap.set("n", "gd", function()
					vim.lsp.buf.definition()
				end, { buffer = bufnr, remap = false, desc = "LSP go to def" })
				vim.keymap.set("n", "<leader>ws", function()
					vim.lsp.buf.workspace_symbol()
				end, { buffer = bufnr, remap = false, desc = "LSP workspace wymbol" })
			end,
		})

		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
			},
		})
		require("neodev").setup({})

		local lspconfig = require("lspconfig")
		local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

		local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
		function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
			opts = opts or {}
			opts.border = opts.border or "single"
			return orig_util_open_floating_preview(contents, syntax, opts, ...)
		end

		require("mason-lspconfig").setup_handlers({
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = lsp_capabilities,
				})
			end,
		})

		lspconfig.lua_ls.setup({
			capabilities = lsp_capabilities,
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = {
						globals = { "vim" },
					},
				},
			},
		})

		lspconfig.clangd.setup({
			capabilities = lsp_capabilities,
			cmd = {
				"clangd",
				"--offset-encoding=utf-16",
			},
		})

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
			if vim.snippet.jumpable(1) then
				return "<cmd>lua vim.snippet.jump(1)<cr>"
			else
				return "<Tab>"
			end
		end, { expr = true, desc = "Jump to next snippet placeholder" })
		vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
			if vim.snippet.jumpable(-1) then
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
		vim.diagnostic.config({
			underline = false,
			virtual_text = true,
			float = {
				header = { "Diagnostics", "FloatTitle" },
				border = "single",
				focusable = true,
			},
		})
	end,
}
