using Gtk;
using Cairo;
using Gdk;

public class BackgroundManager : GLib.Object {
    private static string config_dir = Resources.get_config_dir();
    private static string file_png = config_dir + "/background.png";
    private static string file_jpg = config_dir + "/background.jpg";
    private static bool dynamic_background = false;
    private static double factor_scaling = 1.0;
    private static Cairo.Pattern? pattern = null;
    private static Cairo.ImageSurface? image_sf = null;
    private static Gdk.Pixbuf? image_pf = null;

public static void load_background(int width, int height) {
    dynamic_background = false;
    factor_scaling = 1.0;
    pattern = null;
    image_sf = null;
    image_pf = null;

if (GLib.File.new_for_path(file_jpg).query_exists()) {
    dynamic_background = true;
    try {
        image_pf = new Gdk.Pixbuf.from_file(file_jpg);
        if (image_pf == null) {
            warning("Can't create Pixbuf background: %s", file_jpg);
            image_pf = null;
            factor_scaling = 1.0;
            dynamic_background = false;
        } else {
            int w = image_pf.get_width();
            factor_scaling = (double) width / (double) w;
        }
    } catch (GLib.Error e) {
        warning("Can't create Pixbuf background: %s", e.message);
        image_pf = null;
        factor_scaling = 1.0;
        dynamic_background = false;
    }
} else if (GLib.File.new_for_path(file_png).query_exists()) {
    dynamic_background = true;
    image_sf = new Cairo.ImageSurface.from_png(file_png);
    if (image_sf == null) {
        warning("Can't create PNG background: Cairo.ImageSurface is null");
        image_sf = null;
        pattern = null;
        factor_scaling = 1.0;
        dynamic_background = false;
        return;
    }
    pattern = new Cairo.Pattern.for_surface(image_sf);
    pattern.set_extend(Cairo.Extend.PAD);
    int w = image_sf.get_width();
    factor_scaling = (double) width / (double) w;
}

}

    public static bool draw_background(Gtk.Widget widget, Cairo.Context cr) {
        int width = widget.get_allocated_width();
        int height = widget.get_allocated_height();

        if (dynamic_background) {
            if (image_pf != null) {
                cr.save();
                cr.scale(factor_scaling, factor_scaling);
                Gdk.cairo_set_source_pixbuf(cr, image_pf, 0, 0);
                cr.paint();
                cr.restore();
                return false;
            } else if (pattern != null) {
                cr.save();
                cr.scale(factor_scaling, factor_scaling);
                cr.set_source(pattern);
                cr.paint();
                cr.restore();
                return false;
            }
        }

        // Fallback: draw a vertical gradient background
        var grad = new Cairo.Pattern.linear(0, 0, 0, height);
        grad.add_color_stop_rgb(0, 0.15, 0.18, 0.23); // Top: dark blue/grey
        grad.add_color_stop_rgb(1, 0.09, 0.10, 0.13); // Bottom: darker
        cr.set_source(grad);
        cr.rectangle(0, 0, width, height);
        cr.fill();
        return false;
    }
}
