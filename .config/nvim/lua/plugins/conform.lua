return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				c = { "clang-format" },
				rust = { "rustfmt" },
				-- zig = { "zig fmt" },
				ocaml = { "ocamlformat" },
				haskel = { "fourmolu" },
				javascript = { "prettier" },
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 100,
				lsp_fallback = true,
			},
		})
	end,
}