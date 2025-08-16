namespace LightPad.Frontend {

public struct Color {
    public double R;
    public double G;
    public double B;
    public double A;

    public Color (double R, double G, double B, double A = 1.0) {
        this.R = R;
        this.G = G;
        this.B = B;
        this.A = A;
    }

    public Color set_val (double val) {
        assert (val >= 0 && val <= 1);
        double h, s, v;
        rgb_to_hsv (this.R, this.G, this.B, out h, out s, out v);
        v = val;
        double r, g, b;
        hsv_to_rgb (h, s, v, out r, out g, out b);
        return Color(r, g, b, this.A);
    }

    public Color multiply_sat (double amount) {
        assert (amount >= 0);
        double h, s, v;
        rgb_to_hsv (this.R, this.G, this.B, out h, out s, out v);
        s = Math.fmin (1.0, s * amount);
        double r, g, b;
        hsv_to_rgb (h, s, v, out r, out g, out b);
        return Color(r, g, b, this.A);
    }

    public static void rgb_to_hsv (double r, double g, double b, out double h, out double s, out double v) {
        assert (r >= 0 && r <= 1);
        assert (g >= 0 && g <= 1);
        assert (b >= 0 && b <= 1);
        double min = Math.fmin (r, Math.fmin (g, b));
        double max = Math.fmax (r, Math.fmax (g, b));
        v = max;
        if (v == 0.0) {
            h = 0.0;
            s = 0.0;
            return;
        }
        double delta = max - min;
        s = (max == 0.0) ? 0.0 : delta / max;
        if (s == 0.0) {
            h = 0.0;
        } else {
            if (max == r) {
                h = (g - b) / delta;
            } else if (max == g) {
                h = 2.0 + (b - r) / delta;
            } else {
                h = 4.0 + (r - g) / delta;
            }
            h *= 60.0;
            if (h < 0.0)
                h += 360.0;
        }
    }

    public static void hsv_to_rgb (double h, double s, double v, out double r, out double g, out double b) {
        assert (h >= 0 && h <= 360);
        assert (s >= 0 && s <= 1);
        assert (v >= 0 && v <= 1);
        if (s == 0.0) {
            r = v;
            g = v;
            b = v;
            return;
        }
        double hh = h;
        if (hh >= 360.0) hh = 0.0;
        hh /= 60.0;
        int i = (int) Math.floor (hh);
        double ff = hh - i;
        double p = v * (1.0 - s);
        double q = v * (1.0 - (s * ff));
        double t = v * (1.0 - (s * (1.0 - ff)));
        switch (i) {
            case 0:
                r = v; g = t; b = p;
                break;
            case 1:
                r = q; g = v; b = p;
                break;
            case 2:
                r = p; g = v; b = t;
                break;
            case 3:
                r = p; g = q; b = v;
                break;
            case 4:
                r = t; g = p; b = v;
                break;
            case 5:
            default:
                r = v; g = p; b = q;
                break;
        }
    }

    public Gdk.RGBA to_rgba () {
        var rgba = Gdk.RGBA();
        rgba.red = this.R;
        rgba.green = this.G;
        rgba.blue = this.B;
        rgba.alpha = this.A;
        return rgba;
    }

    public static Color from_rgba (Gdk.RGBA rgba) {
        return Color(rgba.red, rgba.green, rgba.blue, rgba.alpha);
    }

    public static Color from_hex (string hex) {
        string h = hex.strip().replace("#", "");
        double r = 0, g = 0, b = 0, a = 1.0;
        if (h.length == 6 || h.length == 8) {
            r = (double) int.parse("0x" + h.substring(0,2)) / 255.0;
            g = (double) int.parse("0x" + h.substring(2,4)) / 255.0;
            b = (double) int.parse("0x" + h.substring(4,6)) / 255.0;
            if (h.length == 8) {
                a = (double) int.parse("0x" + h.substring(6,8)) / 255.0;
            }
            return Color(r, g, b, a);
        }
        return Color(0, 0, 0, 1.0);
    }

    public string to_hex (bool with_alpha = false) {
        int r = (int)(this.R * 255.0 + 0.5);
        int g = (int)(this.G * 255.0 + 0.5);
        int b = (int)(this.B * 255.0 + 0.5);
        int a = (int)(this.A * 255.0 + 0.5);
        if (with_alpha)
            return "#%02X%02X%02X%02X".printf(r, g, b, a);
        else
            return "#%02X%02X%02X".printf(r, g, b);
    }
}

}
