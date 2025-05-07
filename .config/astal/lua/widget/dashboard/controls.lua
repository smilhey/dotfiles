local Hyprland = astal.require("AstalHyprland")

local refresh_rate = function(gkdmonitor)
	local hypr = Hyprland.get_default()
	local rate, err = astal.exec({ "bash", "-c", "xrandr | rg -F '*' | awk '{print $2}'" })
	if err then
		return
	else
		rate = rate:gsub("[^%d%.]", "")
		rate = Variable(math.ceil(tonumber(rate)))
	end
	local widget = Widget.Box({
		Widget.Button({
			class_name = "element",
			on_click_release = function(_, _)
				if rate:get() == 60 then
					hypr:message_async("keyword monitor eDP-1, 2880x1800@120, 0x0, 2")
					rate:set(120)
				else
					hypr:message_async("keyword monitor eDP-1, 2880x1800@60, 0x0, 2")
					rate:set(60)
				end
			end,
			Widget.Label({
				label = rate(function(r)
					return tostring(r) .. " Hz"
				end),
			}),
		}),
	})
	return widget
end

return refresh_rate
