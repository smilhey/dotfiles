return {
	"stevearc/conform.nvim",
	config = function()
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				-- python = vim.fs.root(0, ".git") == nil and { "black" } or nil,
				python = { "black" },
				lua = { "stylua" },
				c = { "clang_format" },
				rust = { "rustfmt" },
				ocaml = { "ocamlformat" },
				haskel = { "fourmolu" },
				css = { "prettier" },
				json = { "prettier" },
				typst = { "typstfmt" },
				markdown = { "prettier" },
				["*"] = { "injected" },
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_format = "fallback",
			},
			-- format_after_save = { lsp_format = "fallback" },
		})
		conform.formatters.injected = {
			options = {
				ignore_errors = false,
			},
		}
	end,
}
