return {
	"jmbuhr/otter.nvim",
	config = function()
		local otter = require("otter")
		otter.setup({
			lsp = {
				hover = {
					border = "single",
				},
			},
			buffers = {
				set_filetype = false,
				write_to_disk = false,
			},
			strip_wrapping_quote_characters = { "'", '"', "`" },
		})
		local languages = { "python", "markdown", "R" }
		local completion = true
		local diagnostics = true
		-- treesitter query to look for embedded languages
		-- uses injections if nil or not set
		local tsquery = nil

		vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
			pattern = { "*.ipynb", "*.md", "*.Rmd" },
			desc = "Otter actions",
			callback = function()
				local bufnr = vim.api.nvim_get_current_buf()
				otter.activate(languages, completion, diagnostics, tsquery)
				vim.keymap.set("n", "gd", function()
					otter.ask_definition()
				end, { buffer = bufnr })
				vim.keymap.set("n", "K", function()
					otter.ask_hover()
				end, { buffer = bufnr })
				vim.keymap.set("n", "<leader>vrr", function()
					otter.ask_references()
				end, { buffer = bufnr })
				vim.keymap.set("n", "<leader>vrn", function()
					otter.ask_rename()
				end, { buffer = bufnr })
			end,
		})
	end,
}
