const { query } = await Service.import("applications");
const WINDOW_NAME = "applauncher";

const AppItem = (app) =>
    Widget.Button({
        on_clicked: () => {
            App.closeWindow(WINDOW_NAME);
            app.launch();
        },
        attribute: { app },
        child: Widget.Box({
            vertical: true,
            children: [
                Widget.Icon({
                    vpack: "center",
                    hpack: "center",
                    icon: app.icon_name || "",
                    size: 52,
                }),
                Widget.Label({
                    css: "padding-top: 8px;",
                    class_name: "title",
                    label: app.name,
                    vpack: "center",
                    truncate: "end",
                }),
            ],
        }),
    });

const Applauncher = ({ width = 100, height = 20, spacing = 12 }) => {
    let applications = query("").map(AppItem);
    const list = Widget.Box({
        hpack: "center",
        vertical: false,
        children: applications,
        spacing,
    });
    function repopulate() {
        applications = query("").map(AppItem);
        list.children = applications;
    }
    const entry = Widget.Entry({
        css: `box-shadow: none;border: none; margin-bottom: ${spacing}px;`,
        on_accept: () => {
            const results = applications.filter((item) => item.visible);
            if (results[0]) {
                App.toggleWindow(WINDOW_NAME);
                results[0].attribute.app.launch();
            }
        },
        on_change: ({ text }) =>
            applications.forEach((item) => {
                item.visible = item.attribute.app.match(text ?? "");
            }),
    });
    return Widget.Box({
        vertical: true,
        css: `background:rgba(0,0,0,0.6); padding: 20px`,
        children: [
            entry,
            Widget.Scrollable({
                css: `padding: 10px;min-width: ${width}px;` + `min-height: ${height}px;`,
                child: list,
            }),
        ],
        setup: (self) =>
            self.hook(App, (_, windowName, visible) => {
                if (windowName !== WINDOW_NAME) return;
                if (visible) {
                    repopulate();
                    entry.text = "";
                    entry.grab_focus();
                }
            }),
    });
};

export default () => Widget.Window({
    class_name: "launcher",
    anchor: ["top"],
    name: WINDOW_NAME,
    setup: (self) =>
        self.keybind("Escape", () => {
            App.closeWindow(WINDOW_NAME);
        }),
    visible: false,
    layer: "overlay",
    keymode: "exclusive",
    child: Widget.Box({
        css: "padding: 10px;",
        vertical: true,
        children: [
            Applauncher({
                width: 500,
                height: 100,
                spacing: 10,
            })]
    })
})
