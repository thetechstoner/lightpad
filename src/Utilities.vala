using GLib;
using Gtk;
using Cairo;
using Gee;

namespace LightPad.Frontend {

public class Utilities : Object {

    public static void draw_rounded_rectangle(
        Cairo.Context context, double radius, double offset, Gtk.Allocation size
    ) {
        if (context == null) return;
        context.new_sub_path();
        context.arc(size.x + size.width - radius - offset, size.y + radius + offset, radius, -Math.PI/2, 0);
        context.arc(size.x + size.width - radius - offset, size.y + size.height - radius - offset, radius, 0, Math.PI/2);
        context.arc(size.x + radius + offset, size.y + size.height - radius - offset, radius, Math.PI/2, Math.PI);
        context.arc(size.x + radius + offset, size.y + radius + offset, radius, Math.PI, 1.5*Math.PI);
        context.close_path();
    }

    public static LightPad.Frontend.Color average_color(Gdk.Pixbuf source) {
        if (source == null || source.get_pixels() == null)
            return LightPad.Frontend.Color(0.5, 0.5, 0.5, 1.0);
        double rTotal = 0, gTotal = 0, bTotal = 0;
        int n_channels = source.get_n_channels();
        int width = source.get_width();
        int height = source.get_height();
        int rowstride = source.get_rowstride();
        uchar[] pixels = source.get_pixels();
        if (pixels == null || pixels.length == 0)
            return LightPad.Frontend.Color(0.5, 0.5, 0.5, 1.0);
        ulong pixel_count = 0;
        for (int y = 0; y < height; y++) {
            int row = y * rowstride;
            for (int x = 0; x < width; x++) {
                int idx = row + x * n_channels;
                if (idx + 2 >= pixels.length)
                    continue;
                uchar r = pixels[idx];
                uchar g = pixels[idx+1];
                uchar b = pixels[idx+2];
                uchar max = (uchar) Math.fmax(r, Math.fmax(g, b));
                uchar min = (uchar) Math.fmin(r, Math.fmin(g, b));
                double delta = max - min;
                double sat = (max == 0) ? 0.0 : delta / (double) max;
                double score = 0.2 + 0.8 * sat;
                rTotal += r * score;
                gTotal += g * score;
                bTotal += b * score;
                pixel_count++;
            }
        }
        if (pixel_count == 0)
            return LightPad.Frontend.Color(0.5, 0.5, 0.5, 1.0);
        return LightPad.Frontend.Color(
            rTotal / (255.0 * pixel_count),
            gTotal / (255.0 * pixel_count),
            bTotal / (255.0 * pixel_count),
            1.0
        ).set_val(0.8).multiply_sat(1.15);
    }

    public static void truncate_text(
        Cairo.Context context,
        Gtk.Allocation size,
        uint padding,
        string? input,
        out string truncated,
        out Cairo.TextExtents truncated_extents
    ) {
        Cairo.TextExtents extents;
        if (context == null) {
            truncated = "";
            truncated_extents = Cairo.TextExtents();
            return;
        }
        if (input == null) {
            truncated = "";
            context.text_extents("", out truncated_extents);
            return;
        }
        truncated = input;
        context.text_extents(input, out extents);
        if (extents.width > (size.width - padding)) {
            while (truncated.length > 0 && extents.width > (size.width - padding)) {
                truncated = truncated.slice(0, (int)truncated.length - 1);
                context.text_extents(truncated, out extents);
            }
            if (truncated.length > 3) {
                truncated = truncated.slice(0, (int)truncated.length - 3);
                truncated += "...";
            }
        }
        context.text_extents(truncated, out truncated_extents);
    }
}

public class Utils : Object {
    public static int clamp(int value, int min, int max) {
        if (value < min) return min;
        if (value > max) return max;
        return value;
    }

    public static string capitalize(string s) {
        if (s == null || s.length == 0) return s;
        return s.substring(0,1).up() + s.substring(1);
    }

    public static string join_strings(Gee.Collection<string>? items, string separator) {
        if (items == null || items.size == 0) return "";
        var sb = new StringBuilder();
        int i = 0;
        foreach (var item in items) {
            sb.append(item);
            if (++i < items.size) sb.append(separator);
        }
        return sb.str;
    }

    public static string get_map_value(HashMap<string, string>? map, string key, string fallback = "") {
        if (map != null && map.has_key(key)) return map[key];
        return fallback;
    }

    public static Gdk.Pixbuf? load_icon(string? icon_name, int size) {
        try {
            if (icon_name == null || icon_name.strip() == "") return null;
            if (icon_name.has_suffix(".png") || icon_name.has_suffix(".svg") || icon_name.has_suffix(".jpg")) {
                if (GLib.FileUtils.test(icon_name, GLib.FileTest.EXISTS)) {
                    return new Gdk.Pixbuf.from_file_at_size(icon_name, size, size);
                }
            }
            return Gtk.IconTheme.get_default().load_icon(icon_name, size, 0);
        } catch (Error e) {
            return null;
        }
    }

    public static int get_child_index(Gtk.Grid grid, Gtk.Widget? widget) {
        if (widget == null || grid == null) return -1;
        var children = grid.get_children();
        if (children == null) return -1;
        for (int i = 0; i < children.length(); i++) {
            if (children.nth_data(i) == widget) return i;
        }
        return -1;
    }
}

}
