return {
	"3rd/image.nvim",
	ft = { "norg", "markdown", ".ipynb" },
	cond = not vim.g.neovide,
	opts = {
		backend = "kitty", -- whatever backend you would like to use
		integrations = {
			markdown = {
				enabled = true,
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = false,
				filetypes = { "markdown", "vimwiki" },
			},
			neorg = {
				enabled = true,
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = false,
				filetypes = { "norg" },
			},
		},
		max_width = 100,
		max_height = 12,
		max_height_window_percentage = math.huge,
		max_width_window_percentage = math.huge,
		-- weird stuff happens with messages changing kind when this is true
		window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
		window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- render image files as images when opened
		kitty_method = "normal",

		editor_only_render_when_focused = true,
		tmux_show_only_in_active_window = true,
	},
}
