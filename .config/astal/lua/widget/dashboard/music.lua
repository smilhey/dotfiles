local Mpris = astal.require("AstalMpris")

local widget = function(gdkmonitor)
	local mpris = Mpris.get_default()
	return Widget.Box({
		class_name = "element",
		bind(mpris, "players"):as(function(players)
			local player = players[1]
			if player then
				return Widget.Box({
					Widget.Label({ label = bind(player, "title") }),
				})
			end
		end),
	})
end

return widget
