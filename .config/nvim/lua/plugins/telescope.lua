return {
	event = "VeryLazy",
	"nvim-telescope/telescope.nvim",
	dependencies = {
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("telescope").setup({
			extensions = {
				fzf = {
					fuzzy = true, -- false will only do exact matching
					override_generic_sorter = true, -- override the generic sorter
					override_file_sorter = true, -- override the file sorter
					case_mode = "smart_case", -- or "ignore_case" or "respect_case"
				},
			},
			defaults = {
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						results_width = 0.8,
					},
					vertical = {
						mirror = false,
					},
					width = 0.87,
					height = 0.80,
				},
				mappings = {
					-- i = { ["<M-q>"] = "send_to_qflist" },
				},
				border = true,
				-- borderchars = { "━", "┃", "━", "┃", "┏", "┓", "┛", "┗" },
				borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
				path_display = { "truncate" },
				-- file_previewer = require("telescope.previewers").cat.new,
				-- grep_previewer = require("telescope.previewers").vimgrep.new,
				-- qflist_previewer = require("telescope.previewers").qflist.new,
			},
		})
		require("telescope").load_extension("fzf")
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
		vim.keymap.set("n", "<leader>bb", builtin.buffers, { desc = "List Buffers" })
		vim.keymap.set("n", "<leader>gs", builtin.grep_string, { desc = "Grep String under cursor" })
		vim.keymap.set("n", "<leader>lg", builtin.live_grep, { desc = "Live Grep" })
	end,
}
