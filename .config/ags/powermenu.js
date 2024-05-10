import icons from "./icons.js";

const WINDOW_NAME = "powermenu";

const { sleep, reboot, logout, poweroff } = {
    sleep: { cmd: "systemctl suspend", label: "sleep" },
    reboot: { cmd: "reboot", label: "reboot" },
    logout: { cmd: "hyprctl dispatch exit", label: "logout" },
    poweroff: { cmd: "poweroff", label: "shutdown" },
};

const SysButton = (action) =>
    Widget.Button({
        on_clicked: () => Utils.exec(action.cmd),
        child: Widget.Box({
            expand: true,
            hpack: "center",
            vpack: "center",
            vertical: true,
            class_name: "system-button",
            children: [
                Widget.Icon({ icon: icons.powermenu[action.label], size: 30 }),
                Widget.Label({
                    label: action.label,
                    visible: true,
                }),
            ],
        }),
    });

export default () =>
    Widget.Window({
        name: WINDOW_NAME,
        class_name: "powermenu",
        setup: (self) =>
            self.keybind("Escape", () => {
                App.closeWindow(WINDOW_NAME);
            }),
        visible: false,
        keymode: "exclusive",
        anchor: ["top", "left", "right", "bottom"],
        child: Widget.Box({
            hpack: "center",
            vpack: "center",
            spacing: 40,
            children: [
                SysButton(sleep),
                SysButton(reboot),
                SysButton(logout),
                SysButton(poweroff),
            ],
        }),
    });
