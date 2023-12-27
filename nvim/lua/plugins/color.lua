return {
	"blazkowolf/gruber-darker.nvim",
	config = function()
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.cmd.colorscheme("gruber-darker")
	end,
}

-- return {
-- 	"rose-pine/neovim",
-- 	config = function()
-- 		require("rose-pine").setup({ disable_background = true })
-- 		vim.cmd("colorscheme rose-pine")
-- 	end,
-- }

-- return {
-- 	"rebelot/kanagawa.nvim",
-- 	-- Default options:
-- 	config = function()
-- 		require("kanagawa").setup({
-- 			transparent = true, -- do not set background color
-- 			background = { -- map the value of 'background' option to a theme
-- 				dark = "dragon", -- try "dragon" !
-- 				light = "lotus",
-- 			},
-- 		})
-- 		-- setup must be called before loading
-- 		vim.cmd("colorscheme kanagawa")
-- 	end,
-- }

-- return {
-- 	"ellisonleao/gruvbox.nvim",
-- 	priority = 1000,
-- 	config = function()
-- 		require("gruvbox").setup({
-- 			transparent_mode = false,
-- 		})
-- 		vim.o.background = "dark" -- or "light" for light mode
-- 		vim.cmd([[colorscheme gruvbox]])
-- 		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- 		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- 	end,
-- }

-- return {
--     "catppuccin/nvim",
--     name = "catppuccin",
--     priority = 1000,
--     config = function()
--         vim.cmd.colorscheme("catppuccin-latte")
--     end,
-- }
