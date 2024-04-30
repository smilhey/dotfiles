return {
	"jmbuhr/otter.nvim",
	dependencies = { "neovim/nvim-lspconfig", "hrsh7th/nvim-cmp" },
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
			handle_leading_whitespace = true,
		})
		local languages = { "python", "markdown", "R", "neorg" }
		local completion = true
		local diagnostics = true
		-- treesitter query to look for embedded languages
		-- uses injections if nil or not set
		local tsquery = nil

		vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
			pattern = { "*.ipynb", "*.md", "norg" },
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
				vim.keymap.set("n", "crr", function()
					otter.ask_references()
				end, { buffer = bufnr })
				vim.keymap.set("x", "<C-r><C-r>", function()
					otter.ask_references()
				end, { buffer = bufnr })
				vim.keymap.set("x", "<C-r>r", function()
					otter.ask_references()
				end, { buffer = bufnr })
				vim.keymap.set("n", "crn", function()
					otter.ask_rename()
				end, { buffer = bufnr })
			end,
		})
	end,
}
