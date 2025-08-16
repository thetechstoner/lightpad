using Gtk;
using Gee;
using Cairo;
using Pango;

namespace LightPad.Frontend {

public class FolderItem : Gtk.EventBox {
    public Gee.ArrayList<string> apps;
    public string folder_name;
    public int icon_size;
    public double font_size;
    public int item_box_width;
    public int item_box_height;
    public Gee.HashMap<string, string> app_info;
    public signal void folder_activated();
    public signal void folder_rename_requested();

    private Gtk.Label name_label;
    private Gtk.Label desc_label;
    private Gtk.Box main_box;

    public FolderItem(
        Gee.HashMap<string, string> app_info,
        int icon_size,
        int font_size,
        int item_box_width,
        int item_box_height
    ) {
        GLib.Object();
        // Defensive: ensure app_info is never null
        this.app_info = app_info ?? new Gee.HashMap<string, string>();
        this.folder_name = this.app_info.has_key("name") ? this.app_info["name"] : "";
        this.icon_size = icon_size;
        this.font_size = font_size;
        this.item_box_width = item_box_width;
        this.item_box_height = item_box_height;

        // Defensive: ensure apps list is always initialized
        this.apps = new Gee.ArrayList<string>();

        main_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
        this.add(main_box);

        var icon = new Gtk.Image.from_icon_name("folder", Gtk.IconSize.DIALOG);
        main_box.pack_start(icon, false, false, 0);

        name_label = new Gtk.Label(folder_name);
        name_label.set_justify(Gtk.Justification.CENTER);
        name_label.set_ellipsize(Pango.EllipsizeMode.END);
        name_label.set_max_width_chars(18);
        name_label.set_use_markup(true);
        name_label.set_size_request(item_box_width, -1);
        main_box.pack_start(name_label, false, false, 0);

        desc_label = new Gtk.Label("");
        desc_label.set_justify(Gtk.Justification.CENTER);
        desc_label.set_use_markup(true);
        main_box.pack_start(desc_label, false, false, 0);

        update_count();

        Gtk.TargetEntry[] FOLDER_TARGETS = {
            { "APP_ITEM", Gtk.TargetFlags.SAME_APP, 0 }
        };
        Gtk.drag_dest_set(this, Gtk.DestDefaults.ALL, FOLDER_TARGETS, Gdk.DragAction.MOVE);
        this.drag_data_received.connect(on_drag_data_received);

        this.button_press_event.connect((event) => {
            if (event.button == 3) {
                var menu = new Gtk.Menu();
                var rename_item = new Gtk.MenuItem.with_label("Rename");
                rename_item.activate.connect(() => {
                    folder_rename_requested();
                });
                menu.append(rename_item);
                var delete_item = new Gtk.MenuItem.with_label("Delete Folder");
                delete_item.activate.connect(() => {
                    this.destroy();
                });
                menu.append(delete_item);
                menu.show_all();
                menu.popup_at_pointer((Gdk.Event*)event);
                return true;
            }
            return false;
        });

        this.button_release_event.connect((event) => {
            if (event.button == 1) {
                show_folder_popup();
                return true;
            }
            return false;
        });

        this.set_can_focus(true);
        this.focus_in_event.connect(() => {
            this.get_style_context().add_class("folder-selected");
            return false;
        });
        this.focus_out_event.connect(() => {
            this.get_style_context().remove_class("folder-selected");
            return false;
        });
    }

    private void update_count() {
        // Defensive: check apps is not null before use
        int count = (this.apps != null) ? this.apps.size : 0;
        this.desc_label.set_markup("<span size='small'>(%d items)</span>".printf(count));
    }

    public void add_app(string desktop_file) {
        if (this.apps != null && !this.apps.contains(desktop_file)) {
            this.apps.add(desktop_file);
            update_count();
        }
    }

    public void add_app_from_map(Gee.HashMap<string, string> app_map) {
        if (app_map != null && app_map.has_key("desktop_file")) {
            var app_id = app_map["desktop_file"];
            add_app(app_id);
        }
    }

    public void remove_app(string desktop_file) {
        if (this.apps != null && this.apps.contains(desktop_file)) {
            this.apps.remove(desktop_file);
            update_count();
        }
    }

    protected void on_drag_data_received(
        Gdk.DragContext ctx, int x, int y,
        Gtk.SelectionData sel, uint info, uint time
    ) {
        if (sel.get_length() <= 0) {
            Gtk.drag_finish(ctx, false, false, time);
            return;
        }
        string? dropped_data = sel.get_text();
        if (dropped_data != null && this.apps != null && !this.apps.contains(dropped_data)) {
            add_app(dropped_data);
            folder_activated();
        }
        Gtk.drag_finish(ctx, true, false, time);
    }

    protected override bool draw(Cairo.Context ctx) {
        base.draw(ctx);
        if (has_focus) {
            ctx.set_source_rgba(0.9, 0.7, 0.2, 0.15);
            ctx.rectangle(0, 0, this.get_allocated_width(), this.get_allocated_height());
            ctx.fill();
        }
        return false;
    }

    public void show_folder_popup() {
        LightPadWindow? window = this.get_toplevel() as LightPadWindow;
        if (window == null) return;
        var popup = new Gtk.Window(Gtk.WindowType.POPUP);
        popup.set_decorated(false);
        popup.set_modal(true);
        popup.set_resizable(false);

        var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
        box.margin = 12;

        var title = new Gtk.Label("<b>%s</b>".printf(GLib.Markup.escape_text(folder_name)));
        title.set_use_markup(true);
        box.pack_start(title, false, false, 0);

        var grid = new Gtk.Grid();
        grid.set_row_spacing(6);
        grid.set_column_spacing(6);
        int col = 0, row = 0;
        if (this.apps != null) {
            foreach (var app_id in this.apps) {
                var app_info = window.find_app_by_id(app_id);
                if (app_info != null) {
                    var item = new LightPad.Frontend.AppItem(
                        app_info,
                        window.icon_size,
                        (int)window.font_size,
                        window.item_box_width,
                        window.item_box_height
                    );
                    grid.attach(item, col, row, 1, 1);
                    col++;
                    if (col >= 3) { col = 0; row++; }
                }
            }
        }
        box.pack_start(grid, true, true, 0);

        var close_btn = new Gtk.Button.with_label("Close");
        close_btn.clicked.connect(() => { popup.destroy(); });
        box.pack_start(close_btn, false, false, 0);

        popup.add(box);
        popup.show_all();
        popup.set_position(Gtk.WindowPosition.MOUSE);
    }

    public void rename(string new_name) {
        folder_name = new_name;
        this.name_label.set_text(folder_name);
    }
}

}
