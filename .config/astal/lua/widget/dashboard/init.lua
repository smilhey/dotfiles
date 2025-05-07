local battery = require("widget.dashboard.battery")
local controls = require("widget.dashboard.controls")
local tray = require("widget.dashboard.tray")
local music = require("widget.dashboard.music")
local clock = require("widget.dashboard.clock")

return function(gdkmonitor)
	local widget = Widget.Window({
		class_name = "dashboard",
		name = "dashboard",
		gdkmonitor = gdkmonitor,
		exclusivity = "EXCLUSIVE",
		anchor = Astal.WindowAnchor.TOP,
		visible = true,
		application = App,
		Widget.Box({
			hexpand = true,
			vexpand = true,
			battery(gdkmonitor),
			controls(gdkmonitor),
			tray(gdkmonitor),
			clock(),
			music(gdkmonitor),
		}),
	})
	return widget
end
