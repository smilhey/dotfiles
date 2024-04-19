return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"vimdoc",
				"markdown",
				"javascript",
				"lua",
				"markdown_inline",
			},
			-- Automatically install missing parsers when entering buffer
			auto_install = true,
			highlight = {
				-- `false` will disable the whole extension
				enable = true,
			},
			textobjects = {
				move = {
					enable = true,
					set_jumps = false,
					goto_next_start = {
						["]b"] = { query = "@code_cell.inner", desc = "next code block" },
					},
					goto_previous_start = {
						["[b"] = { query = "@code_cell.inner", desc = "previous code block" },
					},
				},
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ib"] = { query = "@code_cell.inner", desc = "in block" },
						["ab"] = { query = "@code_cell.outer", desc = "around block" },
					},
				},
				swap = {
					enable = true,
					swap_next = {
						["<leader>sbl"] = "@code_cell.outer",
						desc = "swap next block",
					},
					swap_previous = {
						["<leader>sbh"] = "@code_cell.outer",
						desc = "swap previous block",
					},
				},
			},
		})
	end,
}
