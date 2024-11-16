local function show_complete_documentation(client, buf)
	local cur_selected
	local prev_request
	local prev_win
	vim.api.nvim_create_autocmd({ "CompleteChanged" }, {
		desc = "LSP completion documentation",
		buffer = buf,
		callback = function()
			if prev_request then
				client.cancel_request(prev_request)
			end
			local selected = vim.fn.complete_info({ "selected" }).selected
			cur_selected = selected
			local completionItem = vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "completion_item")
			if completionItem == nil then
				return
			end
			local docs_handler = function(_err, result)
				if _err ~= nil then
					vim.notify(vim.inspect(_err), vim.log.levels.ERROR)
					return
				end
				if prev_win and vim.api.nvim_win_is_valid(prev_win) then
					vim.api.nvim_win_close(prev_win, true)
				end
				if cur_selected ~= selected then
					return
				end
				local docs = vim.tbl_get(result, "documentation", "value")
				if not docs then
					return
				end
				docs = vim.lsp.util.convert_input_to_markdown_lines(docs)
				docs = table.concat(docs, "\n"):gsub("^\n+", ""):gsub("\n+$", "")
				local winData = vim.api.nvim__complete_set(selected, { info = docs })
				vim.g.doc_win = winData.winid
				if not winData.winid or not vim.api.nvim_win_is_valid(winData.winid) then
					return
				end
				local pum_pos = vim.fn.pum_getpos()
				local win_config = vim.api.nvim_win_get_config(winData.winid)
				local anchor = pum_pos["row"] < vim.fn.winline() and "S" or "N"
				local row = pum_pos["row"] < vim.fn.winline() and vim.fn.winline() - 1 or pum_pos["row"]
				local col
				local width
				if pum_pos["col"] < vim.o.columns - pum_pos["width"] - pum_pos["col"] then
					width = math.min(win_config.width, vim.o.columns - pum_pos["width"] - pum_pos["col"] - 1)
					anchor = anchor .. "W"
					col = pum_pos["col"] + pum_pos["width"]
				else
					width = math.min(win_config.width, pum_pos["col"])
					anchor = anchor .. "E"
					col = pum_pos["col"]
				end
				vim.api.nvim_win_set_config(winData.winid, {
					relative = "editor",
					anchor = anchor,
					row = row,
					col = col,
					width = width,
				})
				prev_win = winData.winid
				if not vim.api.nvim_buf_is_valid(winData.bufnr) then
					return
				end
				vim.lsp.util.stylize_markdown(
					winData.bufnr,
					vim.split(docs, "\n"),
					{ width = width, height = win_config.height }
				)
			end
			_, prev_request =
				client.request(vim.lsp.protocol.Methods.completionItem_resolve, completionItem, docs_handler, buf)
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
				-- auto_complete
				local all_ascii_chars = {}
				for i = 32, 126 do -- ASCII range for printable characters
					table.insert(all_ascii_chars, string.char(i))
				end
				if vim.tbl_get(client.server_capabilities, "completionProvider", "triggerCharacters") ~= nil then
					client.server_capabilities.completionProvider.triggerCharacters = all_ascii_chars
				end
				vim.lsp.completion.enable(true, data.client_id, buf, { autotrigger = true })
				show_complete_documentation(client, buf)
				vim.keymap.set("n", "gd", function()
					vim.lsp.buf.definition()
				end, { buffer = buf, remap = false, desc = "LSP go to def" })
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

		-- local open_floating_preview = vim.lsp.util.open_floating_preview
		-- function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		-- 	opts = opts or {}
		-- 	opts.border = opts.border or "single"
		-- 	return open_floating_preview(contents, syntax, opts, ...)
		-- end

		require("mason-lspconfig").setup_handlers({
			function(server_name)
				lspconfig[server_name].setup({})
			end,
			["lua_ls"] = function()
				lspconfig.lua_ls.setup({
					settings = {
						Lua = {
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true),
							},
							completion = {
								callSnippet = "Replace",
								showParams = false,
							},
							telemetry = {
								enable = false,
							},
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
				-- header = { "Diagnostics", "FloatTitle" },
				-- border = "single",
				focusable = true,
			},
		})
	end,
}
