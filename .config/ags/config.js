import applauncher from "./applauncher.js";
import powermenu from "./powermenu.js";
import brightness from "./services/brightness.js";
import controlcenter from "./controlcenter.js";
import osd from "./osd.js";
import notifications from "./notifications.js";
import overview from "./overview.js";
const audio = await Service.import("audio");

globalThis.Brightness = brightness;
globalThis.Audio = audio;

App.config({
    style: App.configDir + "/style.css",
    windows: [
        applauncher(),
        powermenu(),
        controlcenter(),
        osd(),
        notifications(),
        overview(),
    ],
});
