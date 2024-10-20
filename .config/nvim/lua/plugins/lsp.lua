local function auto_complete(buf, client_id)
	local timer
	local omni_key = vim.keycode("<C-x><C-o>")
	vim.lsp.completion.enable(true, client_id, buf)
	vim.api.nvim_create_autocmd("InsertLeave", {
		desc = "LSP autocomplete",
		buffer = buf,
		callback = function()
			if timer then
				timer:stop()
				timer:close()
				timer = nil
			end
		end,
	})
	vim.api.nvim_create_autocmd("InsertCharPre", {
		desc = "LSP autocomplete",
		buffer = buf,
		callback = function()
			if vim.fn.pumvisible() == 1 or vim.fn.state("m") == "m" then
				if timer then
					timer:stop()
					timer:close()
					timer = nil
				end
				return
			end
			if timer then
				return
			else
				timer = vim.uv.new_timer()
				timer:start(10, 0, function()
					timer:stop()
					timer:close()
					vim.schedule(function()
						vim.api.nvim_feedkeys(omni_key, "m", false)
						timer = nil
					end)
				end)
			end
		end,
	})
end

local function show_complete_documentation(client, buf)
	vim.api.nvim_create_autocmd({ "CompleteChanged" }, {
		desc = "LSP completion documentation",
		buffer = buf,
		callback = function()
			local info = vim.fn.complete_info({ "selected" })
			local completionItem = vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "completion_item")
			if completionItem == nil then
				return
			end
			client.request(vim.lsp.protocol.Methods.completionItem_resolve, completionItem, function(_err, result)
				if _err ~= nil then
					vim.notify(vim.inspect(_err), vim.log.levels.ERROR)
					return
				end
				local docs = vim.tbl_get(result, "documentation", "value")
				if not docs then
					return
				end
				local winData = vim.api.nvim__complete_set(info["selected"], { info = docs })
				if not winData.winid or not vim.api.nvim_win_is_valid(winData.winid) then
					return
				end
				local pum_pos = vim.fn.pum_getpos()
				local row, col, width = pum_pos["row"], pum_pos["col"], pum_pos["width"]
				local win_config = vim.api.nvim_win_get_config(winData.winid)
				local anchor = row < vim.fn.winline() and "SW" or "NW"
				row = row < vim.fn.winline() and vim.fn.winline() or row
				vim.api.nvim_win_set_config(winData.winid, {
					relative = "editor",
					anchor = anchor,
					row = row,
					col = col + width,
					width = win_config.width < vim.o.columns - width - col and win_config.width
						or vim.o.columns - width - col,
				})
				if not vim.api.nvim_buf_is_valid(winData.bufnr) then
					return
				end
				vim.bo[winData.bufnr].filetype = "markdown"
			end, buf)
		end,
	})
end

return {
	"neovim/nvim-lspconfig",
	dependencies = {
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
			desc = "LSP setup",
			callback = function(args)
				local buf, data = args.buf, args.data
				local client = vim.lsp.get_client_by_id(data.client_id)
				if client and client.supports_method("textDocument/inlayHint") then
					vim.api.nvim_buf_create_user_command(buf, "LspInlayHint", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ buf }), { buffer = true })
					end, {})
				end
				auto_complete(buf, data.client_id)
				show_complete_documentation(client, buf)
				vim.keymap.set("n", "gd", function()
					vim.lsp.buf.definition()
				end, { buffer = buf, remap = false, desc = "LSP go to def" })
				vim.keymap.set("n", "<leader>ws", function()
					vim.lsp.buf.workspace_symbol()
				end, { buffer = buf, remap = false, desc = "LSP workspace wymbol" })
			end,
		})

		local kind_symbols = {
			Text = "󰉿",
			Method = "󰆧",
			Function = "󰊕",
			Constructor = "",
			Field = "󰜢",
			Variable = "󰀫",
			Class = "󰠱",
			Interface = "",
			Module = "",
			Property = "󰜢",
			Unit = "󰑭",
			Value = "󰎠",
			Enum = "",
			Keyword = "󰌋",
			Snippet = "",
			Color = "󰏘",
			File = "󰈙",
			Reference = "󰈇",
			Folder = "󰉋",
			EnumMember = "",
			Constant = "󰏿",
			Struct = "󰙅",
			Event = "",
			Operator = "󰆕",
			TypeParameter = "",
		}
		for kind, symbol in pairs(kind_symbols) do
			local index = vim.lsp.protocol.CompletionItemKind[kind]
			vim.lsp.protocol.CompletionItemKind[index] = symbol
		end

		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
			},
		})
		local lspconfig = require("lspconfig")

		local open_floating_preview = vim.lsp.util.open_floating_preview
		function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
			opts = opts or {}
			opts.border = opts.border or "single"
			return open_floating_preview(contents, syntax, opts, ...)
		end

		require("mason-lspconfig").setup_handlers({
			function(server_name)
				lspconfig[server_name].setup({})
			end,
			["lua_ls"] = function()
				local runtime_path = vim.split(package.path, ";")
				table.insert(runtime_path, "lua/?.lua")
				table.insert(runtime_path, "lua/?/init.lua")
				lspconfig.lua_ls.setup({
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
								library = vim.api.nvim_get_runtime_file("", true),
							},
							codeLens = {
								enable = true,
							},
							completion = {
								callSnippet = "Replace",
								showParams = false,
							},
							hint = { enable = true },
							telemetry = {
								enable = false,
							},
							runtime = { version = "LuaJIT", path = runtime_path },
							diagnostics = {
								globals = { "vim" },
							},
						},
					},
				})
			end,
			["clangd"] = function()
				lspconfig.clangd.setup({
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
