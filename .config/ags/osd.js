import icons from "./icons.js";
import brightness from "./services/brightness.js";
const audio = await Service.import("audio");

const DELAY = 2000;
const WINDOW_NAME = "osd";

function osd() {
    const value = Variable(0);
    let count = 0;
    let display = true;
    let ico = Widget.Icon({ css: "padding: 10px" });
    let bar = Widget.Box({
        css: "min-width: 300px;min-height: 100px;",
        class_name: "container",
        children: [
            Widget.LevelBar({
                value: value.bind(),
                hexpand: true,
            }),
        ],
    });
    let rev = Widget.Revealer({
        hpack: "center",
        vpack: "center",
        reveal_child: false,
        child: Widget.Box({
            vertical: true,
            children: [bar, ico],
        }),
    });

    return rev
        .hook(brightness, () => {
            if (!display) return;
            ico.icon = icons.brightness.screen;
            value.setValue(brightness.screen);
            rev.reveal_child = true;
            count++;
            Utils.timeout(2000, () => {
                count--;
                if (count == 0) rev.reveal_child = false;
            });
        })
        .hook(
            audio.speaker,
            () => {
                if (!display) return;
                ico.icon = icons.audio.type.speaker;
                value.setValue(audio.speaker.volume);
                rev.reveal_child = true;
                count++;
                Utils.timeout(DELAY, () => {
                    count--;
                    if (count == 0) rev.reveal_child = false;
                });
            },
            "notify::volume",
        )
        .hook(
            App,
            (_, windowName, visible) => {
                if (windowName == "controlcenter") {
                    if (visible) {
                        rev.reveal_child = false;
                        display = false;
                    } else display = true;
                }
            },
            "window-toggled",
        );
}

function mute() {
    const value = Variable(false);
    let count = 0;
    let ico = Widget.Icon({ size: 42, expand: true });
    let rev = Widget.Revealer({
        reveal_child: false,
        child: Widget.Box({
            class_name: "container",
            hpack: "center",
            vpack: "center",
            css: "min-width: 100px;min-height: 100px;",
            children: [ico],
        }),
    });
    return rev
        .hook(audio.microphone, () => {
            ico.icon = audio.microphone.is_muted
                ? icons.audio.mic.muted
                : icons.audio.mic.unmuted;
            rev.reveal_child = true;
            count++;
            Utils.timeout(DELAY, () => {
                count--;
                if (count == 0) rev.reveal_child = false;
            });
        })
        .hook(
            audio.speaker,
            () => {
                ico.icon = audio.speaker.is_muted
                    ? icons.audio.volume.muted
                    : icons.audio.volume.low;
                rev.reveal_child = true;
                count++;
                Utils.timeout(DELAY, () => {
                    count--;
                    if (count == 0) rev.reveal_child = false;
                });
            },
            "notify::is-muted",
        );
}

export default () =>
    Widget.Window({
        class_name: "osd",
        css: "background-color: rgba(0, 0, 0, 0)",
        layer: "overlay",
        click_through: true,
        visible: true,
        anchor: ["top", "left", "right", "bottom"],
        name: WINDOW_NAME,
        child: Widget.Overlay({
            child: Widget.Box({ expand: true }),
            overlays: [osd(), mute()],
        }),
    });
