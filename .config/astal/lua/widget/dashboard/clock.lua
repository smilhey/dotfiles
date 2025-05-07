local widget = function()
	local time = Variable(""):poll(1000, function()
		return GLib.DateTime.new_now_local():format("%H:%M - %A %e.")
	end)

	return Widget.Box({
		class_name = "element",
		Widget.Label({
			class_name = "clock",
			on_destroy = function()
				time:drop()
			end,
			label = time(),
		}),
	})
end

return widget
