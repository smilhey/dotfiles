import brightness from "./services/brightness.js";
import icons from "./icons.js";
const audio = await Service.import("audio");
const battery = await Service.import("battery");
const WINDOW_NAME = "controlcenter";

const slider = (service, prop, icon) =>
    Widget.Box({
        class_name: "container",
        css: "min-width: 300px;padding: 10px;",
        vertical: false,
        children: [
            Widget.Slider({
                vertical: false,
                expand: true,
                drawValue: false,
                onChange: ({ value }) => (service[prop] = value),
                value: service.bind(prop),
            }),
            Widget.Icon({ css: "padding: 10px; color: white", icon: icon, size: 24 }),
        ],
    });

const battery_level = Widget.Box({
    css: "font-size: 20px; padding: 10px;",
    vpack: "center",
    vertical: true,
    children: [
        Widget.Icon({
            icon: battery.bind("icon_name"),
        }),
        Widget.Label({
            label: battery
                .bind("percent")
                .as((p) => (p > 0 ? p.toString() + "%" : "0%")),
        }),
    ],
});

const clock = Widget.Label({
    css: "font-size: 20px; padding: 10px;",
    setup: (self) => {
        let time = () => (self.label = new Date().toLocaleTimeString());
        time();
        setInterval(time, 1000);
    },
});

const power_button = Widget.Button({
    css: `button:hover {color: red}
    button {color: white; box-shadow: none; border: none; background: rgba(0,0,0,0); font-size: 20px; padding: 10px}`,
    child: Widget.Icon({ icon: icons.powermenu.shutdown }),
    on_clicked: () => { App.toggleWindow(WINDOW_NAME); App.toggleWindow("powermenu"); }
})

const spacer = (w = 30, h = 30, vertical = true) => Widget.Box({
    vertical: vertical,
    css: `background-color: rgba(0,0,0,0); min-width: ${w}px; min-height: ${h}px;`
});

const col = (children) => Widget.Box({
    vertical: true,
    setup(self) {
        let spacedChildren = [];
        for (let i = 0; i < children.length; i++) {
            spacedChildren.push(children[i]);
            if (i < children.length - 1) {
                spacedChildren.push(spacer(30, 30, false));
            }
        }
        self.children = spacedChildren;
    }
})

export default () =>
    Widget.Window({
        name: WINDOW_NAME,
        class_name: "controlcenter",
        keymode: "exclusive",
        setup: (self) =>
            self.keybind("Escape", () => {
                App.closeWindow(WINDOW_NAME);
            }),
        visible: false,
        child: Widget.Box({
            css: "background-color: rgba(0,0,0,0);",
            vertical: true,
            children: [
                col([
                    slider(audio.speaker, "volume", icons.audio.volume.high),
                    slider(brightness, "screen", icons.brightness.screen),
                    Widget.Box({
                        class_name: "container",
                        hexpand: true,
                        hpack: "center",
                        vertical: false,
                        children: [
                            spacer(40, 40, false),
                            power_button,
                            spacer(40, 40, false),
                            battery_level,
                            spacer(40, 40, false),
                            clock,
                            spacer(40, 40, false),
                        ]
                    })
                ])
            ],
        }),
    });
