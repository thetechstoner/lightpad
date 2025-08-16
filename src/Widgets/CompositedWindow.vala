using Gtk;
using Gdk;
using Cairo;

namespace Widgets {

public class CompositedWindow : Gtk.Window {
    construct {
        this.set_skip_taskbar_hint(true);
        this.set_decorated(false);
        this.set_app_paintable(true);
        this.set_name("mainwindow");
        this.set_type_hint(Gdk.WindowTypeHint.DOCK);

        var screen = this.get_screen();
        if (screen != null && screen.is_composited()) {
            var visual = screen.get_rgba_visual();
            if (visual != null) {
                this.set_visual(visual);
            }
        }

        this.draw.connect(clear_background);
        this.set_keep_above(true);
        this.set_skip_pager_hint(true);
        this.set_accept_focus(false);
        this.set_resizable(false);
        this.set_focus_on_map(false);
    }

    public bool clear_background(Gtk.Widget widget, Cairo.Context ctx) {
        if (widget != null && widget.get_realized()) {
            ctx.set_operator(Cairo.Operator.CLEAR);
            ctx.paint();
            ctx.set_operator(Cairo.Operator.OVER);
        }
        return false;
    }
}

}
