return {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		require("fzf-lua").setup({
			winopts = {
				-- border = { " ", " ", " ", " ", " ", " ", " ", " " },
				border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
				-- border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
				preview = {
					default = "bat",
					winopts = {},
					border = "noborder",
					layout = "flex",
				},
			},
			manpages = { previewer = "man_native" },
			helptags = { previewer = "help_native" },
			tags = { previewer = "bat" },
			btags = { previewer = "bat" },
		})
		vim.keymap.set(
			"n",
			"<leader>ff",
			F(fzf.files, {
				fzf_opts = {},
				cwd_prompt = false,
				prompt = "-> ",
			}),
			{ silent = true, noremap = true, desc = "search files" }
		)
		vim.keymap.set(
			"n",
			"<leader>lg",
			F(fzf.live_grep, { fzf_opts = {}, cwd_prompt = false, prompt = "-> " }),
			{ silent = true, noremap = true, desc = "live grep project" }
		)
		vim.keymap.set(
			"n",
			"<leader>bb",
			F(fzf.buffers, { prompt = "-> " }),
			{ silent = true, noremap = true, desc = "list buffers" }
		)
		vim.keymap.set(
			"n",
			"<leader>gs",
			F(fzf.grep_cWORD, { prompt = "-> " }),
			{ silent = true, noremap = true, desc = "grep WORD under string" }
		)
	end,
}
