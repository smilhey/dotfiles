local Battery = astal.require("AstalBattery")

local widget = function(gdkmonitor)
	local screen_width = gdkmonitor:get_geometry().width
	local bat = Battery.get_default()
	local e_var = Variable(""):poll(1000, "upower -d", function(out)
		if type(out) == "string" then
			local energy_rate = out:match("energy%-rate:%s+([%d%.]+)")
			return string.format("%.1f W", energy_rate)
		else
			return ""
		end
	end)
	local energy_rate = Widget.Box({
		css = "margin: 3px",
		Widget.Label({ label = e_var() }),
	})
	local battery_life = Widget.Box({
		css = "margin: 3px",
		Widget.Icon({
			icon = bind(bat, "battery-icon-name"),
		}),
		Widget.Label({
			label = bind(bat, "percentage"):as(function(p)
				return string.format("%.0f%%", p * 100)
			end),
		}),
	})
	local t_var = Variable(""):poll(1000, "upower -d", function(out)
		if type(out) == "string" then
			local time_to_empty = out:match("time to empty:%s+([%d%.]+%s+hours)")
			return time_to_empty
		else
			return ""
		end
	end)
	local time = Widget.Box({
		css = "margin: 3px",
		on_destroy = function()
			t_var:drop()
		end,
		Widget.Label({ label = t_var() }),
	})
	return Widget.Box({ class_name = "element", battery_life, energy_rate, time })
end

return widget
