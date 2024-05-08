import applauncher from "./applauncher.ts";
import powermenu from "./powermenu.ts";
import brightness from "./services/brightness.ts";
import controlcenter from "./controlcenter.ts";
import osd from "./osd.ts";
import notifications from "./notifications.ts";
const audio = await Service.import("audio");

globalThis.Brightness = brightness;
globalThis.Audio = audio;

App.config({
  style: "./style.css",
  windows: [
    applauncher(),
    powermenu(),
    controlcenter(),
    osd(),
    notifications(),
  ],
});
