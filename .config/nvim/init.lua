if vim.g.neovide then
    vim.g.neovide_padding_top = 0
    vim.g.neovide_padding_bottom = 0
    vim.g.neovide_padding_right = 0
    vim.g.neovide_padding_left = 0
    vim.o.guifont = "JetBrainsMono Nerd Font:h16" -- text below applies for VimScript
    vim.g.neovide_scroll_animation_length = 0.15
    vim.g.neovide_cursor_animation_length = 0
    vim.g.neovide_cursor_trail_size = 0
    vim.g.neovide_scale_factor = 1.0
    function Scale(scale)
        vim.g.neovide_scale_factor = scale
    end

    vim.cmd("command! -nargs=1 Scale lua Scale(<args>)")
    vim.cmd("command! -nargs=1 S lua Scale(<args>)")
end
require("config.remap")
require("config.lazy")
require("config.set")
