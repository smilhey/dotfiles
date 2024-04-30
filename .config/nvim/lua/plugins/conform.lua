return {
	"stevearc/conform.nvim",
	config = function()
		local function is_git()
			local cwd = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
			return not vim.tbl_isempty(vim.fs.find(".git", { path = cwd, upward = true, stop = vim.fn.expand("~") }))
		end
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = not is_git() and { "black" } or nil,
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
