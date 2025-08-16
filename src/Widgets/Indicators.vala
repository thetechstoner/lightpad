using Gtk;
using Gee;
using Cairo;

namespace LightPad.Frontend {

public class Indicators : Gtk.HBox {
    const int FPS = 60;
    private int animation_duration = 0;
    private int animation_frames = 0;
    private int current_frame = 0;
    private uint animation_loop_id = 0;
    private bool animation_active = false;

    public signal void child_activated ();
    public new Gee.ArrayList<Gtk.Widget> children;
    public int active = -1;
    private int old_active = -1;
    private int skip_flag = 0;

    public Indicators () {
        Object();
        this.homogeneous = false;
        this.spacing = 0;
        // Defensive: always initialize children
        this.children = new Gee.ArrayList<Gtk.Widget>();
        this.draw.connect(draw_background);
    }

    public void append (string thelabel) {
        var indicator = new Gtk.EventBox ();
        indicator.set_visible_window (false);
        var label = new Gtk.Label (thelabel);
        label.get_style_context ().add_class ("indicator_label");
        label.set_halign (Gtk.Align.CENTER);
        label.set_valign (Gtk.Align.CENTER);
        label.set_margin_top (5);
        label.set_margin_bottom (5);
        label.set_margin_start (15);
        label.set_margin_end (15);
        indicator.add (label);
        if (this.children != null)
            this.children.add (indicator);
        indicator.button_release_event.connect (() => {
            if (this.children != null)
                this.set_active (this.children.index_of (indicator));
            return true;
        });
        this.pack_start (indicator, false, false, 0);
    }

    public void set_active_no_signal (int index) {
        int pages_length = (this.children != null) ? (int) this.children.size : 0;
        if (index >= 0 && index < pages_length) {
            this.old_active = this.active;
            this.active = index;
            this.change_focus ();
        }
    }

    public void set_active (int index) {
        skip_flag++;
        this.set_active_no_signal (index);
        if (skip_flag > 1) {
            this.child_activated ();
        }
    }

    public void change_focus () {
        if (animation_active) {
            GLib.Source.remove (animation_loop_id);
            end_animation ();
        }
        this.animation_duration = 240;
        int difference = (this.old_active - this.active).abs ();
        this.animation_duration += (int) (Math.pow ((double)difference, 0.5) * 80);
        this.animation_frames = 2;
        this.current_frame = 0;
        this.animation_active = true;
        this.animation_loop_id = GLib.Timeout.add ((int)(1000 / FPS), () => {
            if (this.current_frame >= this.animation_frames) {
                end_animation ();
                return false;
            }
            this.current_frame++;
            this.queue_draw ();
            return true;
        });
    }

    private void end_animation () {
        animation_active = false;
        current_frame = 0;
    }

    public void clear () {
        if (this.children != null) {
            foreach (var child in this.children) {
                this.remove(child);
            }
            this.children.clear();
        }
        this.active = -1;
        this.old_active = -1;
        this.skip_flag = 0;
        this.queue_draw();
    }

    protected bool draw_background (Gtk.Widget widget, Cairo.Context ctx) {
        if (widget == null || !widget.get_realized()) {
            return false;
        }
        Gtk.Allocation size;
        widget.get_allocation (out size);
        double d = (double) this.animation_frames;
        double t = (double) this.current_frame;
        double progress = 0.0;
        if (d > 0.0) {
            t = t / d - 1.0;
            progress = t * t * t * t + 1.0;
        }
        Gtk.Widget? old_child = null;
        Gtk.Widget? new_child = null;
        int children_size = (this.children != null) ? this.children.size : 0;
        if (this.old_active >= 0 && this.old_active < children_size)
            old_child = this.children.get(this.old_active);
        if (this.active >= 0 && this.active < children_size)
            new_child = this.children.get(this.active);
        if (old_child == null || new_child == null ||
            !old_child.get_realized() || !new_child.get_realized()) {
            return false;
        }
        Gtk.Allocation size_old, size_new;
        old_child.get_allocation (out size_old);
        new_child.get_allocation (out size_new);
        double x = size_old.x + (size_new.x - (double) size_old.x) * progress;
        double y = size_old.y + (size_new.y - (double) size_old.y) * progress;
        double width = size_old.width + (size_new.width - (double) size_old.width) * progress;
        double height = size_old.height + (size_new.height - (double) size_old.height) * progress;
        double offset = 2.0;
        double radius = 6.0;
        ctx.set_source_rgba (1.0, 1.0, 1.0, 1.0);
        ctx.move_to (x + radius, size.y + offset);
        ctx.arc (x + width / 2, y + height / 2, radius, 0, Math.PI * 2);
        ctx.fill ();
        return false;
    }
}

}
