local habamax = {
	foreground = "#dadada", -- silver
	background = "#1C1C1C", -- black
	-- background = "#101010", -- black
	-- background = "#FAF2EB",

	cursor_bg = "#52ad70",
	cursor_fg = "#000000", -- black
	cursor_border = "#52ad70",

	selection_fg = "#000000", -- black
	selection_bg = "#fffacd",

	scrollbar_thumb = "#222222",

	split = "White",

	ansi = {
		"#1C1C1C", -- black
		"#D75F5F", -- darkred
		"#87AF87", -- darkgreen
		"#AFAF87", -- darkyellow
		"#5F87AF", -- darkblue
		"#AF87AF", -- darkmagenta
		"#5F8787", -- darkcyan
		"#9E9E9E", -- gray
	},

	brights = {
		"#767676", -- darkgray
		"#D7875F", -- red
		"#AFD7AF", -- green
		"#D7D787", -- yellow
		"#87AFD7", -- blue
		"#D7AFD7", -- magenta
		"#87AFAF", -- cyan
		"#BCBCBC", -- white
	},

	indexed = {
		[136] = "#af8700",
	},

	compose_cursor = "orange",

	copy_mode_active_highlight_bg = { Color = "#000000" },
	copy_mode_active_highlight_fg = { AnsiColor = "Black" },
	copy_mode_inactive_highlight_bg = { Color = "#52ad70" },
	copy_mode_inactive_highlight_fg = { AnsiColor = "White" },

	quick_select_label_bg = { Color = "peru" },
	quick_select_label_fg = { Color = "#ffffff" },
	quick_select_match_bg = { AnsiColor = "Navy" },
	quick_select_match_fg = { Color = "#ffffff" },
}

local deepwhite = {
	foreground = "#1A1918", -- hsv(30, 8%, 10%)
	-- base1 = "#595855", -- hsv(45, 4%, 35%)
	-- base2 = "#807E79", -- hsv(43, 5%, 50%)
	-- base3 = "#999791", -- hsv(45, 5%, 60%)
	-- base4 = "#B3B1AD", -- hsv(40, 3%, 70%)
	-- base5 = "#CCCBC6", -- hsv(50, 3%, 80%)
	-- base6 = "#E6E4DF", -- hsv(43, 3%, 90%)
	background = "#FAF2EB", -- hsv(24, 4%, 98%)

	cursor_bg = "#52ad70",
	cursor_fg = "#000000", -- black
	cursor_border = "#52ad70",

	selection_fg = "#000000", -- black
	selection_bg = "#CCCBC6",

	scrollbar_thumb = "#222222",

	split = "Black",

	ansi = {
		"#FAE1C8", -- hsv(30, 20%, 98%)
		"#FAFAC8", -- hsv(60, 20%, 98%)
		-- "#D4FAD4", -- hsv(120, 15%, 98%)
		"#00A600", -- hsv(120, 100%, 65%)
		"#C8FAFA", -- hsv(180, 20%, 98%)
		"#D4D4FA", -- hsv(240, 15%, 98%)
		"#EDD4FA", -- hsv(280, 15%, 98%)
		"#FAD4ED", -- hsv(320, 15%, 98%)
		"#FAD4D4", -- hsv(360, 15%, 98%)
	},

	brights = {
		"#F27900", -- hsv(30, 100%, 95%)
		"#F2F200", -- hsv(60, 100%, 95%)
		"#00A600", -- hsv(120, 100%, 65%)
		"#00A6A6", -- hsv(180, 100%, 65%)
		"#0000A6", -- hsv(240, 100%, 65%)
		"#6F00A6", -- hsv(280, 100%, 65%)
		"#A6006F", -- hsv(320, 100%, 65%)
		"#A60000", -- hsv(360, 100%, 65%)
	},
}

return habamax
