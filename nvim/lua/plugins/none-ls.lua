return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.black, -- python script formatting
				null_ls.builtins.formatting.beautysh, -- shell script formatting
				null_ls.builtins.formatting.ocamlformat, --  ocaml formatting
				null_ls.builtins.formatting.rustfmt, -- rust formatting
				null_ls.builtins.formatting.fourmolu, -- haskell formatting
				null_ls.builtins.formatting.clang_format, -- c formatting
				null_ls.builtins.formatting.zigfmt, -- zig formatting
				null_ls.builtins.formatting.stylua, -- lua formatting
				null_ls.builtins.formatting.prettier, -- javascript formatting
			},
			on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ async = false })
						end,
					})
				end
			end,
		})
	end,
}
