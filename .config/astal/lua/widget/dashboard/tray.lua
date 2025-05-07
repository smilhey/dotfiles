local Tray = astal.require("AstalTray")
local lib = require("lib")

local widget = function(gdkmonitor)
	local tray = Tray.get_default()

	return Widget.Box({
		bind(tray, "items"):as(function(items)
			return lib.map(items, function(item)
				if item.icon_theme_path ~= nil then
					App:add_icons(item.icon_theme_path)
				end
				local menu = item:create_menu()
				return Widget.Button({
					class_name = "element",
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

return widget
