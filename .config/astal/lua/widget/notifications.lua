local timeout = astal.timeout
local Notifd = astal.require("AstalNotifd")
local notifd = Notifd.get_default()
local popup_timeout = 3000
local Widget = require("astal.gtk3.widget")

local notif_item = function(n)
	local app_name = Widget.Label({
		label = n.app_name,
		class_name = "name",
	})

	local summary = Widget.Label({
		label = n.summary,
		class_name = "summary",
		halign = "START",
		valign = "CENTER",
		wrap = true,
		xalign = 0,
	})

	local body = Widget.Label({
		label = n.body,
		class_name = "body",
		halign = "START",
		valign = "START",
		wrap = true,
		xalign = 0,
		-- max_width_chars = 130,
	})

	local app_icon = Widget.Icon({
		icon = lookup_icon({ n.app_name, "application-x-executable" }),
		class_name = string.format(
			"icon %s",
			string.find(n.app_name, "-symbolic", 0, true) ~= nil and "symbolic" or ""
		),
		valign = "CENTER",
		halign = "START",
	})

	local image_path

	if n:get_hint("image-path") then
		image_path = n:get_hint("image-path"):get_data_as_bytes():get_data()
	else
		image_path = n.app_icon
	end

	local image = Widget.Icon({
		css = string.format("font-size: %.5frem", rem(70)),
		class_name = "image",
		valign = "CENTER",
		visible = image_path and #image_path > 1,
		icon = (image_path and #image_path > 1) and image_path or nil,
	})

	return Widget.EventBox({
		on_click_release = function(this)
			this:destroy()
		end,
		Widget.Box({
			orientation = "VERTICAL",
			Widget.Box({
				class_name = "notification-title",
				spacing = 10,
				app_icon,
				app_name,
				Widget.Icon({
					icon = "window-close-symbolic",
					class_name = "icon",
					halign = "END",
					hexpand = true, -- Ensure the icon can expand horizontally
				}),
			}),
			Widget.Box({
				spacing = 10,
				image,
				Widget.Box({
					orientation = "VERTICAL",
					class_name = "notification-box",
					spacing = 10,
					summary,
					body,
				}),
			}),
		}),
	})
end

-- Dynamically fetch Adwaita theme background color
local function get_theme_background()
	local widget = Gtk.Window() -- Temporary widget
	local context = widget:get_style_context()
	local color = context:get_background_color(Gtk.StateFlags.NORMAL)
	widget:destroy() -- Cleanup the temporary widget
	return string.format("#%02x%02x%02x", color.red * 255, color.green * 255, color.blue * 255)
end

local notif_background_color = get_theme_background()
print(notif_background_color)

return function(gdkmonitor)
	return Widget.Window({
		class_name = "notifications",
		width_request = math.floor(gdkmonitor:get_geometry().width / 3),
		setup = function(self)
			local count = 0
			self:hook(notifd, "notified", function()
				count = count + 1
				self.visible = true
			end)
			self:hook(notifd, "resolved", function()
				count = count - 1
				if count == 0 then
					timeout(popup_timeout, function()
						self.visible = false
					end)
				end
			end)
		end,
		Widget.Box({
			css = string.format("padding: 1rem; background-color: %s;", notif_background_color),
			orientation = "VERTICAL",
			class_name = "notifications-container",
			spacing = 10,
		}),
	})
end
