local w = require("wezterm")
local colors = require("colors")
local keys = require("keys")

local config = w.config_builder()

config.warn_about_missing_glyphs = false
config.inactive_pane_hsb = {
	saturation = 1,
	brightness = 1,
}
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.adjust_window_size_when_changing_font_size = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.font = w.font("JetBrains Mono")
config.enable_wayland = false
config.font_size = 15
config.window_background_opacity = 1

config.colors = colors
config.keys = keys

return config
