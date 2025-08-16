using GLib;

public class BaseConfig {
    public int grid_y;
    public int grid_x;
    public int grid_row_spacing;
    public int grid_col_spacing;
    public double item_font_size;
    public int item_icon_size;
    public int item_box_width;
    public int item_box_height;
    public int sb_width;
    public int sb_height;
    public int screen_w;
    public int screen_h;

    public BaseConfig(int screen_width, int screen_height, bool init_default = true) {
        screen_w = screen_width;
        screen_h = screen_height;
        if (init_default) {
            set_defaults();
        }
    }

    private void set_defaults() {
        default_icon_size();
        default_grid_size();
        item_font_size = 14.0;
        item_box_width = item_icon_size * 2;
        item_box_height = item_icon_size + 36;
        grid_row_spacing = 16;
        grid_col_spacing = 16;
        sb_width = 240;
        sb_height = 26;
    }

    private void default_icon_size() {
        double scale_factor = (1.0/3.0);
        double suggested_size = Math.pow(screen_w * screen_w, scale_factor) / 1.7;
        if (suggested_size < 27) {
            this.item_icon_size = 24;
        } else if (suggested_size < 40) {
            this.item_icon_size = 32;
        } else if (suggested_size < 56 || screen_h == 720) {
            this.item_icon_size = 48;
        } else {
            this.item_icon_size = 64;
        }
    }

    private void default_grid_size() {
        double aspect = screen_w / (double) screen_h;
        if (aspect < 1.4) { // 5:4 or 4:3
            grid_x = 5;
            grid_y = 5;
        } else if (screen_h == 600) { // Netbook 1024x600px
            grid_y = 6;
            grid_x = 4;
        } else if (screen_h == 720) { // HD 1280x720px
            grid_y = 7;
            grid_x = 5;
        } else if (screen_h == 1080) { // Full HD 1920x1080px
            grid_y = 9;
            grid_x = 7;
        } else { // Default 16:9
            grid_y = 6;
            grid_x = 5;
        }
    }
}

void merge_int(int* ptr, int val) {
    if (ptr != null && val > -1)
        *ptr = val;
}

void merge_double(double* ptr, double val) {
    if (ptr != null && val > -1.0)
        *ptr = val;
}

public class FileConfig : BaseConfig {
    private KeyFile config_f;

    public FileConfig(int screen_width, int screen_height, string file) {
        base(screen_width, screen_height);
        config_f = new KeyFile();
        if (file == null || file.strip() == "") {
            message("Config file path is invalid. Using default values");
            return;
        }
        try {
            config_f.load_from_file(file, KeyFileFlags.KEEP_COMMENTS);
        } catch (Error e) {
            message("Config file not found. Using default values");
            return;
        }
        const string[] group = {"Grid", "AppItem", "SearchBar"};
        try {
            merge_int(&grid_y, config_f.get_integer(group[0], "Y"));
            merge_int(&grid_x, config_f.get_integer(group[0], "X"));
            merge_int(&grid_row_spacing, config_f.get_integer(group[0], "RowSpacing"));
            merge_int(&grid_col_spacing, config_f.get_integer(group[0], "ColumnSpacing"));
            merge_double(&item_font_size, config_f.get_double(group[1], "FontSize"));
            merge_int(&item_icon_size, config_f.get_integer(group[1], "IconSize"));
            merge_int(&item_box_width, config_f.get_integer(group[1], "BoxWidth"));
            merge_int(&item_box_height, config_f.get_integer(group[1], "BoxHeight"));
            merge_int(&sb_width, config_f.get_integer(group[2], "Width"));
            merge_int(&sb_height, config_f.get_integer(group[2], "Height"));
        } catch (Error e) {
            message("Key config missing: %s", e.message);
        }
    }
}

// Project-wide constants (if required by other files)
public const string PROJECT_NAME = "lightpad";
public const string PACKAGE_SHAREDIR = "/usr/share";
