import Widget from "resource:///com/github/Aylur/ags/widget.js";
import App from "resource:///com/github/Aylur/ags/app.js";
import * as vars from "../../variables.js";
import HoverableButton from "../../misc/HoverableButton.js";
import * as battery from "../../misc/battery.js";
import Clock from "./Clock.js";

const Battery = () =>
  Widget.Box({
    orientation: "horizontal",
    class_name: "battery",
    hpack: "end",
    children: [battery.Indicator(), battery.LevelLabel()],
  });

export default () =>
  Widget.Box({
    class_name: "controlcenter__header",
    children: [
      Widget.Box({
        children: [
          Widget.Label({
            class_name: "controlcenter__uptime",
            binds: [["label", vars.uptime, "value", (t) => `uptime ${t}`]],
          }),
        ],
      }),
      // Widget.Box({
      //     hexpand: true,
      // }),
      Widget.Separator(),
      Clock(),
      Widget.Separator(),
      Battery(),
      Widget.Separator(),
      HoverableButton({
        class_name: "controlcenter__power",
        onPrimaryClickRelease: () => App.toggleWindow("powermenu"),
        child: Widget.Icon({ icon: "system-shutdown", size: 16 }),
      }),
    ],
  });
