import Widget from "resource:///com/github/Aylur/ags/widget.js";

export default ({ ...props } = {}) =>
  Widget.Button({
    cursor: "pointer",
    ...props,
  });
