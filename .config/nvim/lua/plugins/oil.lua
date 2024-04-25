return {
	"stevearc/oil.nvim",
	opts = {},
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local permission_hlgroups = {
			["-"] = "NonText",
			["r"] = "DiagnosticSignWarn",
			["w"] = "DiagnosticSignError",
			["x"] = "DiagnosticSignOk",
		}
		require("oil").setup({
			view_options = {
				-- Show files and directories that start with "."
				show_hidden = true,
			},
			columns = {
				{
					"permissions",
				},
				{ "size", highlight = "Special" },
				{ "mtime", highlight = "Number" },
				{
					"icon",
					default_file = icon_file,
					directory = icon_dir,
					add_padding = false,
				},
			},
			win_options = {
				number = false,
				relativenumber = false,
				signcolumn = "no",
				foldcolumn = "0",
				statuscolumn = "",
			},
			keymaps = {
				["<C-h>"] = false,
				["<C-s>"] = "actions.select_split",
				["<C-v>"] = "actions.select_vsplit",
				["<C-c>"] = false,
				["<C-l>"] = false,
			},
		})
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "oil",
			callback = function()
				vim.keymap.set("n", "q", require("oil").close, { buffer = 0, desc = "Close Oil", nowait = true })
			end,
		})
		vim.keymap.set("n", "<leader>pv", "<cmd>Oil<CR>", { desc = "Navigate project with Oil" })
	end,
}
