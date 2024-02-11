import Widget from "resource:///com/github/Aylur/ags/widget.js";
import App from "resource:///com/github/Aylur/ags/app.js";
import Applications from "resource:///com/github/Aylur/ags/service/applications.js";
import AppItem from "./AppItem.js";
import icons from "../icons.js";
import { launchApp } from "../utils.js";

const WINDOW_NAME = "applauncher";

const Applauncher = () => {
  const list = Widget.Box({ vertical: true });

  const placeholder = Widget.Label({
    label: "  | Couldn't find a match",
    class_name: "placeholder",
  });

  const entry = Widget.Entry({
    hexpand: true,
    text: "-",
    placeholder_text: "Search",
    on_accept: ({ text }) => {
      const list = Applications.query(text);
      if (list[0]) {
        App.toggleWindow(WINDOW_NAME);
        launchApp(list[0]);
      }
    },
    on_change: ({ text }) => {
      list.children = Applications.query(text)
        .map((app) => [Widget.Separator(), AppItem(app)])
        .flat();
      list.add(Widget.Separator());
      list.show_all();

      placeholder.visible = list.children.length === 1;
    },
  });

  return Widget.Box({
    class_name: "applauncher",
    properties: [["list", list]],
    vertical: true,
    children: [
      Widget.Box({
        class_name: "header",
        children: [Widget.Icon(icons.apps.search), entry],
      }),
      Widget.Scrollable({
        hscroll: "never",
        child: Widget.Box({
          vertical: true,
          children: [list, placeholder],
        }),
      }),
    ],
    connections: [
      [
        App,
        (_, name, visible) => {
          if (name !== WINDOW_NAME) return;

          entry.set_text("");
          if (visible) entry.grab_focus();
        },
      ],
    ],
  });
};

export default () =>
  Widget.Window({
    name: WINDOW_NAME,
    popup: true,
    keymode: "exclusive",
    visible: false,
    child: Applauncher(),
  });
