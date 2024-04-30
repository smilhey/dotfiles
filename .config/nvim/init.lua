if vim.g.neovide then
	-- vim.g.neovide_transparency = 0.9
	vim.g.neovide_padding_top = 0
	vim.g.neovide_padding_bottom = 0
	vim.g.neovide_padding_right = 0
	vim.g.neovide_padding_left = 0
	vim.o.guifont = "JetBrainsMono Nerd Font:h16" -- text below applies for VimScript
	vim.g.neovide_scroll_animation_length = 0.15
	vim.g.neovide_cursor_animation_length = 0
	vim.g.neovide_cursor_trail_size = 0
	vim.g.neovide_scale_factor = 1.0

	vim.api.nvim_create_user_command("Scale", function(opts)
		vim.g.neovide_scale_factor = tonumber(opts.fargs[1])
	end, { nargs = 1 })

	vim.api.nvim_create_user_command("S", function(opts)
		vim.g.neovide_scale_factor = tonumber(opts.fargs[1])
	end, { nargs = 1 })
end

require("functions")
require("ui")
require("config.set")
require("config.remap")
require("config.lazy")
require("config.autocmd")
