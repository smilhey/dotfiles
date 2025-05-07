local script_path = debug.getinfo(1, "S").source:match("^@(.+)")
local script_dir = script_path:match("^(.*)/")
package.path = package.path .. ";" .. script_dir .. "/lua/?.lua;" .. script_dir .. "/lua/?/init.lua"
pcall(require, "luarocks.loader")
require("globals")

local scss = os.getenv("HOME") .. "/.config/astal/style.scss"
local css = os.getenv("HOME") .. "/.config/astal/style.scss"
astal.exec(string.format("sass %s %s", scss, css))

local App = require("astal.gtk3.app")
local dashboard = require("widget.dashboard")
-- local notifications = require("widget/notifications")

local Windows = {
	-- notifications = {},
	dashboard = {},
}

App:start({
	css = css,
	main = function()
		for _, gdkmonitor in ipairs(App.monitors) do
			Windows.dashboard[gdkmonitor] = dashboard(gdkmonitor)
			-- Windows.notifications[gdkmonitor] = notifications(gdkmonitor)
		end
	end,
})
