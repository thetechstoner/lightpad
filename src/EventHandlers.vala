using Gtk;

public class EventHandlers : GLib.Object {
    // Handles focus out by hiding and then destroying the widget after 1 second
    public static bool on_focus_out(Gtk.Widget widget, Gdk.EventFocus event) {
        widget.hide();
        GLib.Timeout.add_seconds(1, () => {
            widget.destroy();
            return GLib.Source.REMOVE;
        });
        return true;
    }

    // Handles button release: hides and destroys the widget if click is outside the searchbar
    public static bool on_button_release(Gtk.Widget widget, Gdk.EventButton event) {
        var win = widget as LightPadWindow;
        if (win != null && win.searchbar != null && win.searchbar.get_realized()) {
            Gtk.Allocation alloc;
            win.searchbar.get_allocation(out alloc);
            int abs_x = alloc.x;
            int abs_y = alloc.y;
            Gtk.Widget? parent = win.searchbar.get_parent();
            while (parent != null && parent != win) {
                Gtk.Allocation parent_alloc;
                parent.get_allocation(out parent_alloc);
                abs_x += parent_alloc.x;
                abs_y += parent_alloc.y;
                parent = parent.get_parent();
            }
            if ((event.x >= abs_x && event.x < abs_x + alloc.width) &&
                (event.y >= abs_y && event.y < abs_y + alloc.height)) {
                return false;
            }
        }
        widget.hide();
        GLib.Timeout.add_seconds(1, () => {
            widget.destroy();
            return GLib.Source.REMOVE;
        });
        return true;
    }

    // Handles key press events for navigation and input
    public static bool on_key_press(Gtk.Widget widget, Gdk.EventKey event) {
        var win = widget as LightPadWindow;
        if (win == null) return false;
        string? key = Gdk.keyval_name(event.keyval);
        if (key == null) return false;
        switch (key) {
            case "Escape":
                win.destroy();
                return true;
            case "ISO_Left_Tab":
                win.page_left();
                return true;
            case "Shift_L":
            case "Shift_R":
                return true;
            case "Tab":
                win.page_right();
                return true;
            case "Return":
                if (win.filtered.size >= 1) {
                    var focused = win.get_focus();
                if (focused is Gtk.Button) {
                    ((Gtk.Button)focused).clicked();
                }

                }
                return true;
            case "BackSpace":
                if (win.searchbar.text.length > 0) {
                    win.searchbar.text = win.searchbar.text.slice(0, (int) win.searchbar.text.length - 1);
                }
                return true;
            case "Left": {
                int current_item = get_child_index(win, win.get_focus());
                if (current_item % win.grid_x == 0) {
                    win.page_left();
                    return true;
                }
                break;
            }
            case "Right": {
                int current_item = get_child_index(win, win.get_focus());
                if ((current_item + 1) % win.grid_x == 0) {
                    win.page_right();
                    return true;
                }
                break;
            }
            case "Down":
            case "Up":
                break;
            default: {
                unichar ch = Gdk.keyval_to_unicode(event.keyval);
                if (ch >= 32 && !((ch >= 127 && ch <= 159))) {
                    win.searchbar.text += ch.to_string();
                }
                break;
            }
        }
        return false;
    }

    // Handles scroll events for paging
    public static bool on_scroll(Gtk.Widget widget, Gdk.EventScroll event) {
        var win = widget as LightPadWindow;
        if (win == null) return false;
        win.scroll_times += 1;
        var direction = event.direction.to_string();
        if ((direction == "GDK_SCROLL_UP" || direction == "GDK_SCROLL_LEFT")
            && (win.scroll_times >= win.SCROLL_SENSITIVITY)) {
            win.page_left();
            win.scroll_times = 0;
        } else if ((direction == "GDK_SCROLL_DOWN" || direction == "GDK_SCROLL_RIGHT")
            && (win.scroll_times >= win.SCROLL_SENSITIVITY)) {
            win.page_right();
            win.scroll_times = 0;
        }
        return false;
    }

    // Returns the index of the child widget in the grid
    public static int get_child_index(LightPadWindow win, Gtk.Widget? widget) {
        if (widget == null) return -1;
        var children = win.grid.get_children();
        for (int i = 0; i < children.length(); i++) {
            if (children.nth_data(i) == widget) return i;
        }
        return -1;
    }
}
