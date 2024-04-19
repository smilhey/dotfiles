local w = require("wezterm")
local act = w.action

local function is_vim(pane)
	return pane:get_title() == "nvim"
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = w.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

local keys = {
	-- move between split panes
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	-- resize panes
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),
}

for i = 1, 8 do
	table.insert(keys, {
		key = tostring(i),
		mods = "ALT",
		action = act.ActivateTab(i - 1),
	})
end

table.insert(keys, {
	key = ";",
	mods = "CTRL",
	action = act.ActivateCommandPalette,
})

table.insert(keys, {
	key = "t",
	mods = "ALT",
	action = act.SpawnTab("CurrentPaneDomain"),
})

table.insert(keys, {
	key = "w",
	mods = "ALT",
	action = act.CloseCurrentTab({ confirm = true }),
})

table.insert(keys, {
	key = "p",
	mods = "ALT",
	action = act.CloseCurrentPane({ confirm = true }),
})

return keys
