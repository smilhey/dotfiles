const notifications = await Service.import("notifications");

function NotificationIcon({ app_entry, app_icon, image }) {
  if (image) {
    return Widget.Box({
      css:
        `background-image: url("${image}");` +
        "background-size: contain;" +
        "background-repeat: no-repeat;" +
        "background-position: center;",
    });
  }

  let icon = "dialog-information-symbolic";
  if (Utils.lookUpIcon(app_icon)) icon = app_icon;

  if (app_entry && Utils.lookUpIcon(app_entry)) icon = app_entry;

  return Widget.Box({
    child: Widget.Icon(icon),
  });
}

function Notification(n) {
  const icon = Widget.Box({
    css: "padding: 10px",
    vpack: "start",
    class_name: "icon",
    child: NotificationIcon(n),
  });

  const title = Widget.Label({
    xalign: 0,
    justification: "left",
    hexpand: true,
    max_width_chars: 24,
    truncate: "end",
    wrap: true,
    label: n.summary,
    use_markup: true,
  });

  const body = Widget.Label({
    //css: "font-size: 40px",
    hexpand: true,
    use_markup: true,
    xalign: 0,
    justification: "left",
    label: n.body,
    wrap: true,
  });

  const actions = Widget.Box({
    class_name: "actions",
    children: n.actions.map(({ id, label }) =>
      Widget.Button({
        class_name: "action-button",
        on_clicked: () => {
          n.invoke(id);
          n.dismiss();
        },
        hexpand: true,
        child: Widget.Label(label),
      }),
    ),
  });

  return Widget.EventBox({
    attribute: { id: n.id },
    on_primary_click: n.dismiss,
    expand: true,
    vpack: "center",
    child: Widget.Box({
      css: "padding: 10px",
      hpack: "center",
      class_name: `notification ${n.urgency}`,
      vertical: true,
      children: [
        Widget.Box([icon, Widget.Box({ vertical: true }, title, body)]),
        actions,
      ],
    }),
  });
}

export default (monitor = 0) => {
  const list = Widget.Box({
    class_name: "container",
    vertical: true,
    expand: true,
    css: "min-width: 300px; min-height: 100px;" + "padding:10px",
    children: notifications.popups.map(Notification),
  });

  const rev = Widget.Revealer({
    child: list,
  });

  function onNotified(_, id) {
    const n = notifications.getNotification(id);
    if (n) {
      list.children = [Notification(n), ...list.children];
      rev.reveal_child = true;
    }
  }

  function onDismissed(_, id) {
    list.children.find((n) => n.attribute.id === id)?.destroy();
    rev.reveal_child = false;
  }

  list
    .hook(notifications, onNotified, "notified")
    .hook(notifications, onDismissed, "dismissed");

  return Widget.Window({
    layer: "overlay",
    monitor,
    name: `notifications${monitor}`,
    class_name: "notification",
    anchor: ["top"],
    child: Widget.Box({
      css: "padding: 10px;",
      vertical: true,
      child: rev,
    }),
  });
};
