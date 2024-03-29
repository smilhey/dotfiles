import Service from "resource:///com/github/Aylur/ags/service.js";
import Utils from "resource:///com/github/Aylur/ags/utils.js";
import Audio from "resource:///com/github/Aylur/ags/service/audio.js";

import icons from "../icons.js";
import { getAudioTypeIcon } from "../utils.js";
import Brightness from "./Brightness.js";

class Indicator extends Service {
  static {
    Service.register(this, {
      popup: ["double", "string"],
    });
  }

  _delay = 1000;
  _count = 0;

  popup(value, icon) {
    this.emit("popup", value, icon);
    this._count++;
    Utils.timeout(this._delay, () => {
      this._count--;

      if (this._count === 0) this.emit("popup", -1, icon);
    });
  }

  speaker() {
    this.popup(Audio.speaker.volume, getAudioTypeIcon(Audio.speaker.iconName));
  }

  display() {
    // brightness is async, so lets wait a bit
    Utils.timeout(100, () =>
      this.popup(Brightness.screen, icons.brightness.screen),
    );
  }

  kbd() {
    // brightness is async, so lets wait a bit
    Utils.timeout(100, () =>
      this.popup((Brightness.kbd * 33 + 1) / 100, icons.brightness.keyboard),
    );
  }

  connect(event = "popup", callback) {
    return super.connect(event, callback);
  }

  // TODO remove
  connectWidget(widget, callback) {
    Utils.connect(this, widget, callback, "popup");
  }
}

export default new Indicator();
