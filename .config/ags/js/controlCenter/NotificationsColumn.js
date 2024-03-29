import icons from "../icons.js";
import Notification from "../notifications/Notification.js";
import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Notifications from "resource:///com/github/Aylur/ags/service/notifications.js";
import HoverableButton from "../misc/HoverableButton.js";

const ClearButton = () =>
  HoverableButton({
    hpack: "end",
    class_name: "notifications__clear-button",
    on_clicked: () => Notifications.clear(),
    binds: [["sensitive", Notifications, "notifications", (n) => n.length > 0]],
    child: Widget.Box({
      children: [Widget.Label("Clear all")],
    }),
  });

const NotificationList = () =>
  Widget.Box({
    vertical: true,
    vexpand: true,
    connections: [
      [
        Notifications,
        (box) => {
          box.children = Notifications.notifications
            .reverse()
            .map(Notification);

          box.visible = Notifications.notifications.length > 0;
        },
      ],
    ],
  });

const Placeholder = () =>
  Widget.Box({
    class_name: "placeholder",
    vertical: true,
    vpack: "center",
    hpack: "center",
    vexpand: true,
    hexpand: true,
    children: [
      Widget.Icon(icons.notifications.silent),
      Widget.Label("Your inbox is empty"),
    ],
    binds: [["visible", Notifications, "notifications", (n) => n.length === 0]],
  });

export default () =>
  Widget.Box({
    class_name: "notifications",
    vertical: true,
    children: [
      Widget.Scrollable({
        class_name: "notification-scrollable",
        hscroll: "never",
        vscroll: "automatic",
        child: Widget.Box({
          class_name: "notification-list",
          vertical: true,
          children: [NotificationList(), Placeholder()],
        }),
      }),
      ClearButton(),
    ],
  });
