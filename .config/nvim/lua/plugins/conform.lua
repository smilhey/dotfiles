return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = not Git() and { "black" } or nil,
				c = { "clang_format" },
				rust = { "rustfmt" },
				-- zig = { "zig fmt" },
				ocaml = { "ocamlformat" },
				haskel = { "fourmolu" },
				javascript = { "prettier" },
				json = { "prettier" },
				typst = { "typstfmt" },
				markdown = { "prettier" },
			},
			-- format_on_save = {
			-- 	-- These options will be passed to conform.format()
			-- 	timeout_ms = 500,
			-- 	lsp_fallback = true,
			-- },
			format_after_save = { lsp_fallback = true },
		})
	end,
}
