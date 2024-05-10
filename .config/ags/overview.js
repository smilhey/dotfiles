import Gdk from "gi://Gdk";
import Gtk from "gi://Gtk?version=3.0";
import cairo from "gi://cairo";
const hyprland = await Service.import("hyprland");
const apps = await Service.import("applications");
import icons from "./icons.js";

const DEF = { h: 1080, w: 1920 };
const SCALE = 0.3;
const WINDOW_NAME = "overview";
const TARGET = [Gtk.TargetEntry.new("text/plain", Gtk.TargetFlags.SAME_APP, 0)];
const dispatch = (args) => hyprland.messageAsync(`dispatch ${args}`);

function createSurfaceFromWidget(widget) {
    const alloc = widget.get_allocation();
    const surface = new cairo.ImageSurface(
        cairo.Format.ARGB32,
        alloc.width,
        alloc.height,
    );
    const cr = new cairo.Context(surface);
    cr.setSourceRGBA(2, 255, 255, 0);
    cr.rectangle(0, 0, alloc.width, alloc.height);
    cr.fill();
    widget.draw(cr);
    return surface;
}

const window = (client) =>
    Widget.Box(
        {
            css: `padding:5px; min-width: ${client.size[0] * SCALE}px; min-height: ${client.size[1] * SCALE}px;`,
        },
        Widget.Button({
            css: `border: none;box-shadow: none;border-radius:0px;font-size: 24px; background: rgba(0, 0, 0, 0.8);`,
            expand: true,
            class_name: "client",
            attribute: client.address,
            tooltip_text: `${client.title}`,
            child: Widget.Icon({
                icon: (
                    apps.list.find((app) => app.match(client.class)) || { icon_name: "" }
                ).icon_name,
            }),
            on_secondary_click: () =>
                dispatch(`closewindow address:${client.address}`),
            on_clicked: () => {
                dispatch(`focuswindow address:${client.address}`);
                App.closeWindow("overview");
            },
            setup: (btn) =>
                btn
                    .on("drag-data-get", (_w, _c, data) =>
                        data.set_text(client.address, client.address.length),
                    )
                    .on("drag-begin", (_, context) => {
                        Gtk.drag_set_icon_surface(context, createSurfaceFromWidget(btn));
                        btn.toggleClassName("hidden", true);
                    })
                    .on("drag-end", () => btn.toggleClassName("hidden", false))
                    .drag_source_set(
                        Gdk.ModifierType.BUTTON1_MASK,
                        TARGET,
                        Gdk.DragAction.COPY,
                    ),
        }),
    );

const workspace = (id) => {
    const fixed = Widget.Fixed();

    async function update() {
        const json = await hyprland.messageAsync("j/clients").catch(() => null);
        if (!json) return;

        fixed.get_children().forEach((ch) => ch.destroy());
        const clients = JSON.parse(json);
        clients
            .filter(({ workspace }) => workspace.id === id)
            .forEach((c) => {
                const x = c.at[0] - (hyprland.getMonitor(c.monitor)?.x || 0);
                const y = c.at[1] - (hyprland.getMonitor(c.monitor)?.y || 0);
                c.mapped && fixed.put(window(c), x * SCALE, y * SCALE);
            });
        fixed.show_all();
    }

    return Widget.Box({
        attribute: { id },
        tooltipText: `${id}`,
        class_name: "workspace",
        vpack: "center",
        css: `padding: 10px; background: rgba(0, 0, 0, 0); min-width: ${DEF.w * SCALE}px; min-height: ${DEF.h * SCALE}px; `,
        setup(box) {
            box.hook(Variable(1), update);
            box.hook(hyprland, update, "notify::clients");
            box.hook(hyprland.active.client, update);
            box.hook(hyprland.active.workspace, () => {
                box.toggleClassName("active", hyprland.active.workspace.id === id);
            });
        },
        child: Widget.EventBox({
            on_primary_click: () => {
                App.closeWindow("overview");
                dispatch(`workspace ${id}`);
            },
            setup: (eventbox) => {
                eventbox.drag_dest_set(
                    Gtk.DestDefaults.ALL,
                    TARGET,
                    Gdk.DragAction.COPY,
                );
                eventbox.connect("drag-data-received", (_w, _c, _x, _y, data) => {
                    const address = new TextDecoder().decode(data.get_data());
                    dispatch(`movetoworkspacesilent ${id},address:${address}`);
                });
            },
            child: fixed,
        }),
    });
};

const Overview = () =>
    Widget.Scrollable({
        vscroll: "never",
        child: Widget.Box({
            class_name: "overview horizontal",
            children: hyprland.workspaces
                .map(({ id }) => workspace(id))
                .sort((a, b) => a.attribute.id - b.attribute.id),
            setup: (w) => {
                w.hook(
                    hyprland,
                    (w, id) => {
                        if (id === undefined) return;
                        w.children = w.children.filter(
                            (ch) => ch.attribute.id !== Number(id),
                        );
                    },
                    "workspace-removed",
                );
                w.hook(
                    hyprland,
                    (w, id) => {
                        if (id === undefined) return;
                        w.children = [...w.children, workspace(Number(id))].sort(
                            (a, b) => a.attribute.id - b.attribute.id,
                        );
                    },
                    "workspace-added",
                );
            },
        }),
    }).hook(hyprland, (self, w, id) => {
        const ws = hyprland.workspaces.length <= 3 ? hyprland.workspaces.length : 3;
        self.css = `min-width: ${DEF.w * SCALE * ws * 1.1}px;` + `min-height: ${DEF.h * SCALE * 1.1}px;`
    });

export default () =>
    Widget.Window({
        name: WINDOW_NAME,
        layer: "overlay",
        class_name: "overview",
        css: "background-color:rgba(0,0,0,0);",
        setup: (self) =>
            self.keybind("Escape", () => {
                App.closeWindow(WINDOW_NAME);
            }),
        keymode: "exclusive",
        visible: false,
        child: Overview(),
    });
