import NotificationsColumn from "./NotificationsColumn.js";
import Microphone from "./widgets/Microphone.js";
import DND from "./widgets/DND.js";
import Media from "./widgets/Media.js";
import Brightness from "./widgets/Brightness.js";
import Header from "./widgets/Header.js";

import Widget from "resource:///com/github/Aylur/ags/widget.js";
import { Volume } from "./widgets/Volume.js";
import { NetworkToggle } from "./widgets/Network.js";
import { BluetoothToggle } from "./widgets/Bluetooth.js";

const Row = (toggles, menus = []) =>
  Widget.Box({
    class_name: "row",
    vertical: true,
    children: [
      Widget.Box({
        children: toggles,
      }),
      ...menus,
    ],
  });

export default () =>
  Widget.Window({
    name: "controlcenter",
    popup: true,
    visible: false,
    child: Widget.Box({
      class_name: "controlcenter__container",
      children: [
        Widget.Box({
          vertical: true,
          children: [
            Row([NetworkToggle(), Widget.Separator(), BluetoothToggle()]),
            Widget.Separator(),
            Row([Microphone(), Widget.Separator(), DND()]),
            Widget.Separator(),
            Row([
              Widget.Box({
                class_name: "slider-box",
                vertical: true,
                children: [
                  Row([Volume()]),
                  Widget.Separator(),
                  Row([Brightness()]),
                ],
              }),
            ]),
            Media(),
            Widget.Separator(),
            Widget.Box({
              vexpand: true,
            }),
            Widget.Separator(),
            Header(),
          ],
        }),
        NotificationsColumn(),
      ],
    }),
  });
