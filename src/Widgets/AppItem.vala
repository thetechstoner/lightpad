using Gtk;
using Gee;

namespace LightPad.Frontend {

public class AppItem : Gtk.EventBox {
    public Gee.HashMap<string, string> app_info;
    public int icon_size;
    public int font_size;
    public int item_box_width;
    public int item_box_height;
    private Gtk.Image icon_widget;
    protected Gtk.Label name_label;
    protected Gtk.Label desc_label;
    private Gtk.Box wrapper;

    public signal void item_dropped(AppItem source, AppItem target);

    public enum AppDragTargets {
        TARGET_ENTRY_LIST,
        TARGET_APP_ITEM
    }

    private static Gtk.TargetEntry[] APP_DRAG_TARGETS = {
        { "APP_ITEM", Gtk.TargetFlags.SAME_APP, AppDragTargets.TARGET_APP_ITEM },
        { "ENTRY_LIST", Gtk.TargetFlags.SAME_APP, AppDragTargets.TARGET_ENTRY_LIST }
    };

    construct {
        Gtk.drag_source_set(this,
            Gdk.ModifierType.BUTTON1_MASK,
            APP_DRAG_TARGETS,
            Gdk.DragAction.MOVE
        );
        this.drag_begin.connect((ctx) => {
            var pixbuf = this.icon_widget.get_pixbuf();
            if (pixbuf != null) {
                var icon = new Gtk.Image.from_pixbuf(pixbuf);
                Gtk.drag_set_icon_widget(ctx, icon, 0, 0);
            }
        });
        this.drag_data_get.connect((ctx, sel, info, time) => {
            if (this.app_info != null && this.app_info.has_key("desktop_file")) {
                var desktop_file = this.app_info["desktop_file"];
                if (desktop_file != null) {
                    sel.set(
                        Gdk.Atom.intern_static_string("text/plain"),
                        8,
                        (uint8[]) desktop_file.data
                    );
                }
            }
        });
        Gtk.drag_dest_set(this,
            Gtk.DestDefaults.ALL,
            APP_DRAG_TARGETS,
            Gdk.DragAction.MOVE
        );
        this.drag_drop.connect((ctx, x, y, time) => {
            var source_item = Gtk.drag_get_source_widget(ctx) as AppItem;
            if (source_item != null && source_item != this) {
                this.item_dropped(source_item, this);
            }
            return true;
        });
    }

    public AppItem(
        Gee.HashMap<string, string>? app_info,
        int icon_size,
        int font_size,
        int box_width,
        int box_height
    ) {
        // Defensive: ensure app_info is never null
        this.app_info = app_info ?? new Gee.HashMap<string, string>();
        this.icon_size = icon_size;
        this.font_size = font_size;
        this.item_box_width = box_width;
        this.item_box_height = box_height;
        this.set_visible_window(false);
        this.can_focus = true;
        this.set_size_request(box_width, box_height);

        this.wrapper = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
        this.wrapper.set_halign(Gtk.Align.CENTER);
        this.wrapper.set_valign(Gtk.Align.CENTER);

        this.icon_widget = new Gtk.Image();
        this.icon_widget.set_pixel_size(this.icon_size);
        this.icon_widget.set_halign(Gtk.Align.CENTER);
        this.wrapper.pack_start(this.icon_widget, false, false, 0);

        this.name_label = new Gtk.Label("");
        this.name_label.set_halign(Gtk.Align.CENTER);
        this.name_label.set_ellipsize(Pango.EllipsizeMode.END);
        this.name_label.set_max_width_chars(24);
        this.name_label.set_line_wrap(false);
        this.name_label.set_use_markup(true);
        this.name_label.set_justify(Gtk.Justification.CENTER);
        this.name_label.set_margin_top(4);
        this.name_label.set_margin_bottom(0);
        this.wrapper.pack_start(this.name_label, false, false, 0);

        this.desc_label = new Gtk.Label("");
        this.desc_label.set_halign(Gtk.Align.CENTER);
        this.desc_label.set_ellipsize(Pango.EllipsizeMode.END);
        this.desc_label.set_max_width_chars(32);
        this.desc_label.set_line_wrap(true);
        this.desc_label.set_use_markup(true);
        this.desc_label.set_justify(Gtk.Justification.CENTER);
        this.desc_label.get_style_context().add_class("dim-label");
        this.desc_label.set_margin_top(0);
        this.desc_label.set_margin_bottom(2);
        this.wrapper.pack_start(this.desc_label, false, false, 0);

        this.add(this.wrapper);

        this.draw.connect(this.draw_background);
        this.focus_in_event.connect(() => { this.focus_in(); return true; });
        this.focus_out_event.connect(() => { this.focus_out(); return true; });

        // Set initial app info if provided
        set_app_info(
            (this.app_info != null && this.app_info.has_key("name")) ? this.app_info["name"] : "",
            (this.app_info != null && this.app_info.has_key("description")) ? this.app_info["description"] : "",
            null, // Icon will be set later if needed
            (this.app_info != null && this.app_info.has_key("command")) ? this.app_info["command"] : ""
        );
    }

    public void set_app_info(string? name, string? description, Gdk.Pixbuf? icon, string? command) {
        if (icon != null) {
            this.icon_widget.set_from_pixbuf(icon);
        } else {
            this.icon_widget.clear();
        }
        if (name != null && name.strip() != "") {
            this.name_label.set_markup("<b>" + GLib.Markup.escape_text(name) + "</b>");
        } else {
            this.name_label.set_markup("<b>Unknown</b>");
        }
        if (description != null && description.strip() != "") {
            this.desc_label.set_markup("<span size='small'>" + GLib.Markup.escape_text(description) + "</span>");
        } else {
            this.desc_label.set_markup("");
        }
        if (name != null && name.strip() != "" && description != null && description.strip() != "")
            this.set_tooltip_text("%s\n%s".printf(name, description));
        else if (name != null && name.strip() != "")
            this.set_tooltip_text(name);
        else
            this.set_tooltip_text("");
    }

    public void change_app(Gdk.Pixbuf? new_icon, string? new_name, string? new_tooltip) {
        set_app_info(new_name, new_tooltip, new_icon, "");
    }

    public virtual void focus_in() {
        this.get_style_context().add_class("selected");
    }

    public virtual void focus_out() {
        this.get_style_context().remove_class("selected");
    }

    protected virtual bool draw_background(Gtk.Widget widget, Cairo.Context ctx) {
        if (widget == null || !widget.get_realized()) {
            return false;
        }
        Gtk.Allocation size;
        widget.get_allocation(out size);
        if (this.has_focus) {
            ctx.set_source_rgba(0.2, 0.5, 0.9, 0.18); // semi-transparent highlight
            ctx.rectangle(0, 0, size.width, size.height);
            ctx.fill();
        }
        return false;
    }
}

}
