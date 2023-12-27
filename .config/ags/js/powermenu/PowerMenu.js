import Widget from "resource:///com/github/Aylur/ags/widget.js";
import icons from "../icons.js";
import PowerMenu from "../services/powermenu.js";
import ShadedPopup from "./ShadedPopup.js";
import Separator from "../misc/Separator.js";

/**
 * @param {'sleep' | 'reboot' | 'logout' | 'shutdown'} action
 * @param {string} label
 */
const SysButton = (action, label) =>
  Widget.Button({
    class_name: "powermenu_button",
    on_clicked: () => PowerMenu.action(action),
    child: Widget.Box({
      class_name: "powermenu_button_box",
      vertical: true,
      vpack: "center",
      hpack: "center",
      vexpand: true,
      hexpand: true,
      children: [
        Widget.Icon({
          icon: icons.powermenu[action],
          class_name: "powermenu_icon",
          size: 40,
        }),
        Widget.Label(label),
      ],
    }),
  });

export default () =>
  ShadedPopup({
    class_name: "powermenu",
    name: "powermenu",
    expand: true,
    child: Widget.Box({
      children: [
        SysButton("sleep", "Sleep"),
        Separator(),
        SysButton("reboot", "Reboot"),
        Separator(),
        SysButton("logout", "Log Out"),
        Separator(),
        SysButton("shutdown", "Shutdown"),
      ],
    }),
  });
