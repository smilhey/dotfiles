import { USER } from "resource:///com/github/Aylur/ags/utils.js";
import Notifications from "./notifications/Notifications.js";
import ControlCenter from "./controlCenter/ControlCenter.js";
import Applauncher from "./applauncher/Applauncher.js";
import OSD from "./osd/OSD.js";
import PowerMenu from "./powermenu/PowerMenu.js";
import * as setup from "./utils.js";
import { forMonitors } from "./utils.js";
import DND from "./controlCenter/widgets/DND.js";
import { BluetoothDevices } from "./controlCenter/widgets/Bluetooth.js";
import { WifiSelection } from "./controlCenter/widgets/Network.js";
import { AppMixer } from "./controlCenter/widgets/Volume.js";
import { SinkSelector } from "./controlCenter/widgets/Volume.js";
import App from "resource:///com/github/Aylur/ags/app.js";
import Indicator from "./services/onScreenIndicator.js";
import Brightness from "./services/Brightness.js";
import Audio from "resource:///com/github/Aylur/ags/service/audio.js";

setup.warnOnLowBattery();
setup.reloadCss();
setup.globalServices();

globalThis.Audio = Audio;
globalThis.Brightness = Brightness;
globalThis.Indicator = Indicator;
globalThis.App = App;

const windows = () => [
  forMonitors(Notifications),
  forMonitors(OSD),
  ControlCenter(),
  Applauncher(),
  // DND(),
  // BluetoothDevices(),
  // WifiSelection(),
  // AppMixer(),
  // SinkSelector(),
  PowerMenu(),
];

Notifications.cacheActions = true;
Notifications.PopupTimeout = 5000; // milliseconds

export default {
  windows: windows().flat(2),
  maxStreamVolume: 1.5,
  closeWindowDelay: {
    quicksettings: 300,
    dashboard: 300,
  },
  style: `/home/${USER}/.config/ags/style.css`,
};
