-- if vim.g.neovide then
-- 	return {}
-- else
-- 	return {
-- 		"3rd/image.nvim",
-- 		opts = {
-- 			backend = "kitty", -- whatever backend you would like to use
-- 			max_width = 100,
-- 			max_height = 12,
-- 			max_height_window_percentage = math.huge,
-- 			max_width_window_percentage = math.huge,
-- 			window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
-- 			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
-- 		},
-- 	}
-- end

return {
	"3rd/image.nvim",
	cond = not vim.g.neovide,
	opts = {
		backend = "kitty", -- whatever backend you would like to use
		max_width = 100,
		max_height = 12,
		max_height_window_percentage = math.huge,
		max_width_window_percentage = math.huge,
		window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
		window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
	},
}
