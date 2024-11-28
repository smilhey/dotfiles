local Battery = astal.require("AstalBattery")
local Hyprland = astal.require("AstalHyprland")
local Mpris = astal.require("AstalMpris")
local Tray = astal.require("AstalTray")
local lib = require("lib")

local refresh_rate = function()
	-- local hypr = Hyprland.get_default()
	local rate = Variable("60 Hz")
	local widget = Widget.Box({
		Widget.Button({
			on_click_release = function(_, _)
				if rate:get() == "60 Hz" then
					-- hypr:message_async("keyword monitor eDP-1, 2880x1800@120, 0x0, 2")
					rate:set("120 Hz")
				else
					-- hypr:message_async("keyword monitor eDP-1, 2880x1800@60, 0x0, 2")
					rate:set("60 Hz")
				end
			end,
			Widget.Label({
				label = rate(tostring),
			}),
		}),
	})
	return widget
end

local battery = function()
	local bat = Battery.get_default()
	local energy_rate = Widget.Box({
		Widget.Label({
			label = bind(bat, "energy_rate"):as(function(p)
				return p .. " W"
			end),
		}),
	})
	local battery_life = Widget.Box({
		Widget.Icon({
			icon = bind(bat, "battery-icon-name"),
		}),
		Widget.Label({
			label = bind(bat, "percentage"):as(function(p)
				return string.format("%.0f%%", p * 100)
			end),
		}),
	})
	local time = Widget.Box({
		Widget.Label({
			label = bind(bat, "time_to_empty"):as(function(p)
				return string.format("%.1f h", p / 3600)
			end),
		}),
	})
	return Widget.Box({ battery_life, energy_rate, time })
end

local sys_tray = function()
	local tray = Tray.get_default()

	return Widget.Box({
		bind(tray, "items"):as(function(items)
			return lib.map(items, function(item)
				if item.icon_theme_path ~= nil then
					App:add_icons(item.icon_theme_path)
				end
				local menu = item:create_menu()
				return Widget.Button({
					tooltip_markup = bind(item, "tooltip_markup"),
					on_destroy = function()
						if menu ~= nil then
							menu:destroy()
						end
					end,
					on_click_release = function(self, event)
						switch(event.button)
							.case("PRIMARY", function()
								menu:activate()
							end)
							.case("SECONDARY", function()
								if menu ~= nil then
									menu:popup_at_widget(self, "SOUTH", "NORTH", nil)
								end
							end)
							.process()
					end,
					Widget.Icon({
						g_icon = bind(item, "gicon"),
					}),
				})
			end)
		end),
	})
end

local time = function()
	local time = Variable(""):poll(1000, function()
		return GLib.DateTime.new_now_local():format("%H:%M - %A %e.")
	end)

	return Widget.Label({
		class_name = "Time",
		on_destroy = function()
			time:drop()
		end,
		label = time(),
	})
end

local music = function()
	local mpris = Mpris.get_default()
	return Widget.Box({
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

return function()
	local widget = Widget.Window({
		name = "dashboard",
		visible = false,
		application = App,
		Widget.Box({ hexpand = true, vexpand = true, battery(), refresh_rate(), sys_tray(), time(), music() }),
	})
	return widget
end
