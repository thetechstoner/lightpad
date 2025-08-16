using Gtk;
using Cairo;

namespace LightPad.Frontend {

public class Searchbar : Gtk.Box {
    const int WIDTH = 240;
    const int HEIGHT = 26;

    public Gtk.Entry entry;
    public Gtk.Image search_icon;
    private Gtk.Image clear_icon;
    private Gtk.EventBox clear_icon_wrapper;
    private bool is_hinted = true;
    public string hint_string;
    public signal void changed ();

    public string text {
        owned get {
            string current_text = this.entry.get_text ();
            return (current_text == this.hint_string && this.is_hinted) ? "" : current_text;
        }
        set {
            this.entry.set_text (value);
            if (this.entry.get_text () == "") {
                this.hint ();
            } else {
                this.reset_font ();
                this.clear_icon_wrapper.visible = true;
            }
        }
    }

    public Searchbar (string hint) {
        Object();
        this.hint_string = hint;
        this.set_homogeneous (false);
        this.set_can_focus (false);
        this.set_size_request (WIDTH, HEIGHT);

        var wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 3);
        this.add (wrapper);

        var search_icon_wrapper = new Gtk.EventBox ();
        this.search_icon = new Gtk.Image.from_icon_name ("edit-find-symbolic", Gtk.IconSize.MENU);
        search_icon_wrapper.set_visible_window (false);
        search_icon_wrapper.add (this.search_icon);
        search_icon_wrapper.border_width = 4;
        search_icon_wrapper.button_release_event.connect ( () => { return true; } );
        wrapper.pack_start (search_icon_wrapper, false, true, 3);

        this.entry = new Gtk.Entry ();
        this.entry.set_text (this.hint_string);
        this.entry.set_has_frame (false);
        this.entry.set_alignment (0.0f);
        this.entry.set_placeholder_text (this.hint_string);
        this.entry.set_hexpand (true);
        this.entry.set_halign (Gtk.Align.START);
        wrapper.pack_start (this.entry, true, true, 0);

        this.clear_icon_wrapper = new Gtk.EventBox ();
        this.clear_icon_wrapper.set_visible_window (false);
        this.clear_icon_wrapper.border_width = 4;
        this.clear_icon = new Gtk.Image.from_icon_name ("edit-clear-symbolic", Gtk.IconSize.MENU);
        this.clear_icon_wrapper.add (this.clear_icon);
        this.clear_icon_wrapper.button_release_event.connect ( () => { this.hint (); return true; });
        this.clear_icon_wrapper.set_hexpand (true);
        this.clear_icon_wrapper.set_halign (Gtk.Align.END);
        wrapper.pack_end (this.clear_icon_wrapper, false, true, 3);

        this.entry.changed.connect (on_changed);
        this.entry.focus_in_event.connect ((event) => { this.unhint (); return false; });
        this.entry.focus_out_event.connect ((event) => { if (this.entry.get_text () == "") this.hint (); return false; });

        this.draw.connect (this.draw_background);
        this.realize.connect (() => {
            this.hint ();
        });
    }

    public void hint () {
        this.is_hinted = true;
        this.entry.set_text (this.hint_string);
        this.clear_icon_wrapper.visible = false;
        this.entry.get_style_context ().remove_class ("search_normal");
        this.entry.get_style_context ().add_class ("search_greyout");
    }

    public void unhint () {
        if (this.is_hinted) {
            this.entry.set_text ("");
            this.reset_font ();
        }
    }

    private void reset_font () {
        this.entry.get_style_context ().remove_class ("search_greyout");
        this.entry.get_style_context ().add_class ("search_normal");
        this.is_hinted = false;
        this.clear_icon_wrapper.visible = true;
    }

    private void on_changed () {
        if (!this.is_hinted) {
            this.changed ();
        }
    }

    private bool draw_background (Gtk.Widget widget, Cairo.Context ctx) {
        if (widget != null && widget.get_realized()) {
            widget.get_style_context().add_class("search_bg");
        }
        return false;
    }
}

}
