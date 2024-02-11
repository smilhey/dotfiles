// import icons from "../icons.js";
// import PopupWindow from "../misc/PopupWindow.js";
// import App from "resource:///com/github/Aylur/ags/app.js";
// import Variable from "resource:///com/github/Aylur/ags/variable.js";
// import Widget from "resource:///com/github/Aylur/ags/widget.js";
// import * as Utils from "resource:///com/github/Aylur/ags/utils.js";
// import HoverableButton from "../misc/HoverableButton.js";
//
// export const opened = Variable("");
// App.connect("window-toggled", (_, name, visible) => {
//   if (name === "quicksettings" && !visible)
//     Utils.timeout(500, () => (opened.value = ""));
// });
//
// export const Arrow = (name) =>
//   HoverableButton({
//     class_name: "arrow",
//     child: Widget.Icon({
//       icon: icons.ui.arrow.right,
//     }),
//     on_clicked: () => App.toggleWindow(name),
//   });
//
// export const ArrowToggleButton = ({
//   name,
//   icon,
//   label,
//   status,
//   activate,
//   deactivate,
//   activateOnArrow = true,
//   connection: [service, condition],
// }) =>
//   Widget.Box({
//     class_name: "quicksettings__button",
//     connections: [
//       [
//         service,
//         (box) => {
//           box.toggleClassName("active", condition());
//         },
//       ],
//     ],
//     children: [
//       HoverableButton({
//         child: Widget.Box({
//           hexpand: true,
//           children: [
//             icon,
//             Widget.Box({
//               hpack: "start",
//               vpack: "center",
//               vertical: true,
//               children: [label, status],
//             }),
//           ],
//         }),
//         on_clicked: () => {
//           if (condition()) {
//             deactivate();
//             if (opened.value === name) opened.value = "";
//           } else {
//             activate();
//           }
//         },
//       }),
//       Arrow(name, activateOnArrow && activate),
//     ],
//   });
//
// export const SimpleToggleButton = ({
//   icon,
//   label,
//   status,
//   toggle,
//   connection: [service, condition],
// }) =>
//   Widget.Box({
//     class_name: "quicksettings__button",
//     connections: [
//       [
//         service,
//         (box) => {
//           box.toggleClassName("active", condition());
//         },
//       ],
//     ],
//     children: [
//       HoverableButton({
//         child: Widget.Box({
//           hexpand: true,
//           children: [
//             icon,
//             Widget.Box({
//               hpack: "start",
//               vpack: "center",
//               vertical: true,
//               children: [label, status],
//             }),
//           ],
//         }),
//         on_clicked: () => toggle(),
//       }),
//     ],
//   });
//
// export const Menu = ({ name, icon, title, menu_content }) =>
//   PopupWindow({
//     name: name,
//     layout: "center",
//     hexpand: true,
//     vexpand: true,
//     content: Widget.Box({
//       class_names: ["menu", name],
//       vertical: true,
//       children: [
//         Widget.Box({
//           class_name: "title horizontal",
//           children: [icon, title],
//         }),
//         Widget.Separator(),
//         ...menu_content,
//       ],
//     }),
//   });

import Widget from "resource:///com/github/Aylur/ags/widget.js";
import App from "resource:///com/github/Aylur/ags/app.js";
import Variable from "resource:///com/github/Aylur/ags/variable.js";
import * as Utils from "resource:///com/github/Aylur/ags/utils.js";
import icons from "../icons.js";

/** name of the currently opened menu  */
export const opened = Variable("");
App.connect("window-toggled", (_, name, visible) => {
  if (name === "quicksettings" && !visible)
    Utils.timeout(500, () => (opened.value = ""));
});

/**
 * @param {string} name - menu name
 * @param {(() => void) | false=} activate
 */
export const Arrow = (name, activate) => {
  let deg = 0;
  let iconOpened = false;
  const icon = Widget.Icon(icons.ui.arrow.right).hook(opened, () => {
    if (
      (opened.value === name && !iconOpened) ||
      (opened.value !== name && iconOpened)
    ) {
      const step = opened.value === name ? 10 : -10;
      iconOpened = !iconOpened;
      for (let i = 0; i < 9; ++i) {
        Utils.timeout(15 * i, () => {
          deg += step;
          icon.setCss(`-gtk-icon-transform: rotate(${deg}deg);`);
        });
      }
    }
  });
  return Widget.Button({
    child: icon,
    on_clicked: () => {
      opened.value = opened.value === name ? "" : name;
      if (typeof activate === "function") activate();
    },
  });
};

/**
 * @param {Object} o
 * @param {string} o.name - menu name
 * @param {import('gi://Gtk').Gtk.Widget} o.icon
 * @param {import('gi://Gtk').Gtk.Widget} o.label
 * @param {() => void} o.activate
 * @param {() => void} o.deactivate
 * @param {boolean=} o.activateOnArrow
 * @param {[import('gi://GObject').GObject.Object, () => boolean]} o.connection
 */
export const ArrowToggleButton = ({
  name,
  icon,
  label,
  activate,
  deactivate,
  activateOnArrow = true,
  connection: [service, condition],
}) =>
  Widget.Box({
    class_name: "toggle-button",
    setup: (self) =>
      self.hook(service, () => {
        self.toggleClassName("active", condition());
      }),
    children: [
      Widget.Button({
        child: Widget.Box({
          hexpand: true,
          class_name: "label-box horizontal",
          children: [icon, label],
        }),
        on_clicked: () => {
          if (condition()) {
            deactivate();
            if (opened.value === name) opened.value = "";
          } else {
            activate();
          }
        },
      }),
      Arrow(name, activateOnArrow && activate),
    ],
  });

/**
 * @param {Object} o
 * @param {string} o.name - menu name
 * @param {import('gi://Gtk').Gtk.Widget} o.icon
 * @param {import('gi://Gtk').Gtk.Widget} o.title
 * @param {import('gi://Gtk').Gtk.Widget[]} o.content
 */
export const Menu = ({ name, icon, title, content }) =>
  Widget.Revealer({
    transition: "slide_down",
    reveal_child: opened.bind().transform((v) => v === name),
    child: Widget.Box({
      class_names: ["menu", name],
      vertical: true,
      children: [
        Widget.Box({
          class_name: "title horizontal",
          children: [icon, title],
        }),
        Widget.Separator(),
        ...content,
      ],
    }),
  });

/**
 * @param {Object} o
 * @param {import('gi://Gtk').Gtk.Widget} o.icon
 * @param {() => void} o.toggle
 * @param {[import('gi://GObject').GObject.Object, () => boolean]} o.connection
 */
export const SimpleToggleButton = ({
  icon,
  toggle,
  connection: [service, condition],
}) =>
  Widget.Button({
    class_name: "simple-toggle",
    setup: (self) =>
      self.hook(service, () => {
        self.toggleClassName("active", condition());
      }),
    child: icon,
    on_clicked: toggle,
  });
