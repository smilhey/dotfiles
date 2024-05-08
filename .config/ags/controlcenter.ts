import brightness from './services/brightness.ts'
import icons from './icons.ts'
const audio = await Service.import('audio')
const battery = await Service.import('battery')
const WINDOW_NAME = "controlcenter";

const slider = (service, prop, icon) => Widget.Box({
    css: "min-height: 300px;padding: 10px;",
    vertical: true,
    children: [
        Widget.Slider({
            inverted: true,
            vexpand: true,
            vertical: true,
            drawValue: false,
            onChange: ({ value }) => service[prop] = value,
            value: service.bind(prop),
        }),
        Widget.Icon({ css: 'padding: 10px; color: white', icon: icon, size: 24 })
    ]
})


const battery_level = Widget.Box({
    css: "font-size: 20px; padding: 10px;",
    vpack: 'center',
    vertical: true,
    children: [
        Widget.Icon({
            icon: battery.bind('icon_name')
        }),
        Widget.Label({ label: battery.bind('percent').as(p => p > 0 ? p.toString() + '%' : "0%") })
    ]
})

const clock = Widget.Label({
    css: "font-size: 20px; padding: 10px;",
    setup: (self) => { let time = () => self.label = new Date().toLocaleTimeString(); time(); setInterval(time, 1000) }
})

export default () => Widget.Window({
    name: WINDOW_NAME,
    class_name: "controlcenter",
    keymode: "exclusive",
    setup: (self) =>
        self.keybind("Escape", () => {
            App.closeWindow(WINDOW_NAME);
        }),
    visible: false,
    child: Widget.Box({
        class_name: "container",
        vertical: false,
        children: [slider(audio.speaker, 'volume', icons.audio.volume.high), slider(brightness, 'screen', icons.brightness.screen), battery_level, clock]
    })
})
