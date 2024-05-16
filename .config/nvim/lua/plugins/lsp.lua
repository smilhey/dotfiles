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
	},
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "LSP actions",
			callback = function(args)
				local buf, data = args.buf, args.data
				local client = vim.lsp.get_client_by_id(data.client_id)
				if client and client.supports_method("textDocument/inlayHint") then
					vim.api.nvim_buf_create_user_command(buf, "LspInlayHint", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ buf }), { buffer = true })
					end, {})
				end
				vim.keymap.set("n", "gd", function()
					vim.lsp.buf.definition()
				end, { buffer = buf, remap = false, desc = "LSP go to def" })
				vim.keymap.set("n", "<leader>ws", function()
					vim.lsp.buf.workspace_symbol()
				end, { buffer = buf, remap = false, desc = "LSP workspace wymbol" })
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

		local open_floating_preview = vim.lsp.util.open_floating_preview
		function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
			opts = opts or {}
			opts.border = opts.border or "single"
			return open_floating_preview(contents, syntax, opts, ...)
		end

		require("mason-lspconfig").setup_handlers({
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = lsp_capabilities,
				})
			end,
			["lua_ls"] = function()
				lspconfig.lua_ls.setup({
					capabilities = lsp_capabilities,
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
							},
							codeLens = {
								enable = true,
							},
							completion = {
								callSnippet = "Replace",
							},
							hint = { enable = true },
							runtime = { version = "LuaJIT" },
							diagnostics = {
								globals = { "vim" },
							},
						},
					},
				})
			end,
			["clangd"] = function()
				lspconfig.clangd.setup({
					capabilities = lsp_capabilities,
					cmd = {
						"clangd",
						"--offset-encoding=utf-16",
					},
				})
			end,
		})
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
