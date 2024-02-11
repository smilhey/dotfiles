import Gtk from "gi://Gtk";
import Widget from "resource:///com/github/Aylur/ags/widget.js";

export default (props) =>
  Widget({
    ...props,
    type: Gtk.Spinner,
    active: true,
  });
