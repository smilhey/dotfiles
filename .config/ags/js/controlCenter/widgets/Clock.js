import GLib from "gi://GLib";
import Widget from "resource:///com/github/Aylur/ags/widget.js";

export default ({ format = "%H:%M", interval = 1000 } = {}) =>
  Widget.Box({
    hexpand: true,
    vpack: "center",
    hpack: "center",
    children: [
      Widget.Label({
        class_name: "clock__label",
        connections: [
          [
            interval,
            (label) =>
              (label.label = GLib.DateTime.new_now_local().format(format)),
          ],
        ],
      }),
    ],
  });
