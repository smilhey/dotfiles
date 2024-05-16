return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				python = vim.fs.root(0, ".git") == nil and { "black" } or nil,
				lua = { "stylua" },
				c = { "clang_format" },
				rust = { "rustfmt" },
				ocaml = { "ocamlformat" },
				haskel = { "fourmolu" },
				css = { "prettier" },
				json = { "prettier" },
				typst = { "typstfmt" },
				markdown = { "prettier" },
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_fallback = true,
			},
			-- format_after_save = { lsp_fallback = true },
		})
	end,
}
