local script_path = debug.getinfo(1, "S").source:match("^@(.+)")
local script_dir = script_path:match("^(.*)/")
package.path = package.path .. ";" .. script_dir .. "/lua/?.lua"

pcall(require, "luarocks.loader")
require("globals")
local App = require("astal.gtk3.app")
local dashboard = require("widget/dashboard")
local notifications = require("widget/notifications")

local Windows = {
	notifications = {},
}

App:start({
	main = function()
		dashboard()
		for _, gdkmonitor in ipairs(App.monitors) do
			Windows.notifications[gdkmonitor] = notifications(gdkmonitor)
		end
	end,
})
