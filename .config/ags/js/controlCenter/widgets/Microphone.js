import icons from "../../icons.js";
import { SimpleToggleButton } from "../ToggleButton.js";
import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Audio from "resource:///com/github/Aylur/ags/service/audio.js";

export default () =>
  SimpleToggleButton({
    icon: Widget.Icon({
      connections: [
        [
          Audio,
          (icon) => {
            icon.icon = Audio.microphone?.isMuted
              ? icons.audio.mic.muted
              : icons.audio.mic.unmuted;
          },
          "microphone-changed",
        ],
      ],
    }),
    label: Widget.Label({
      class_name: "title",
      hpack: "start",
      label: "Microphone",
    }),
    status: Widget.Label({
      hpack: "start",
      connections: [
        [
          Audio,
          (label) => {
            label.label = !Audio.microphone?.isMuted ? "Enabled" : "Disabled";
          },
        ],
      ],
    }),
    toggle: () => (Audio.microphone.isMuted = !Audio.microphone.isMuted),
    connection: [Audio, () => !Audio.microphone?.isMuted],
  });
