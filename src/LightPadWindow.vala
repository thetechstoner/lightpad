using Gtk;
using Gee;
using LightPad.Frontend;

public class LightPadWindow : Widgets.CompositedWindow {
    public static string user_home = GLib.Environment.get_variable("HOME");

    public Gtk.Box main_container;
    public Gtk.Box bottom_bar;
    public Gtk.Grid grid;
    public LightPad.Frontend.Searchbar searchbar;
    public LightPad.Frontend.Indicators page_indicators;
    public int monitor_width;
    public int monitor_height;
    public int icon_size;
    public int font_size;
    public int item_box_width;
    public int item_box_height;
    public int grid_x;
    public int grid_y;
    public int scroll_times = 0;
    public int SCROLL_SENSITIVITY = 2;

    public LightPadWindow () {
        var display = Gdk.Display.get_default();
        var monitor = display.get_primary_monitor() ?? display.get_monitor(0);
        var geometry = monitor.get_geometry();
        monitor_width = geometry.width / monitor.get_scale_factor();
        monitor_height = geometry.height / monitor.get_scale_factor();
        var config = new FileConfig(
            monitor_width,
            monitor_height,
            Resources.get_config_file()
        );
        icon_size = config.item_icon_size;
        font_size = (int) config.item_font_size;
        item_box_width = config.item_box_width;
        item_box_height = config.item_box_height;
        grid_x = config.grid_x;
        grid_y = config.grid_y;

        this.set_title("LightPad");
        this.set_skip_pager_hint(true);
        this.set_skip_taskbar_hint(true);
        this.set_type_hint(Gdk.WindowTypeHint.NORMAL);
        this.fullscreen_on_monitor(monitor.get_display().get_default_screen(), 0);
        this.set_default_size(monitor_width, monitor_height);

        main_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
        var wrapper = new Gtk.EventBox();
        wrapper.set_visible_window(false);
        wrapper.add(main_container);
        this.add(wrapper);

        bottom_bar = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        searchbar = new LightPad.Frontend.Searchbar("Search");
        bottom_bar.pack_start(searchbar, false, true, (monitor_width / 2) - 120);
        main_container.pack_start(bottom_bar, false, true, 32);

        grid = new Gtk.Grid();
        grid.set_row_spacing(config.grid_row_spacing);
        grid.set_column_spacing(config.grid_col_spacing);
        grid.set_halign(Gtk.Align.CENTER);
        main_container.pack_start(grid, true, true, 0);

        page_indicators = new LightPad.Frontend.Indicators();
        var pages_wrapper = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        pages_wrapper.set_size_request(-1, 30);
        main_container.pack_end(pages_wrapper, false, true, 15);
        pages_wrapper.pack_start(page_indicators, true, false, 0);

        searchbar.changed.connect((_) => {
            GridManager.search(
                searchbar.text, grid,
                icon_size, font_size, item_box_width, item_box_height, grid_x, grid_y
            );
            GridManager.update_indicators(page_indicators);
        });
        page_indicators.child_activated.connect(() => {
            GridManager.update_grid(
                grid, icon_size, font_size, item_box_width, item_box_height, grid_x, grid_y
            );
        });

        GridManager.populate_grid(
            grid, icon_size, font_size, item_box_width, item_box_height, grid_x, grid_y
        );
        GridManager.update_indicators(page_indicators);

        this.draw.connect(BackgroundManager.draw_background);
        this.focus_out_event.connect(EventHandlers.on_focus_out);
        this.button_release_event.connect(EventHandlers.on_button_release);
        this.key_press_event.connect(EventHandlers.on_key_press);
        this.scroll_event.connect(EventHandlers.on_scroll);
    }

    // For keyboard navigation and indicators
    public void page_left() {
        AppManager.prev_page();
        GridManager.populate_grid(
            grid, icon_size, font_size, item_box_width, item_box_height, grid_x, grid_y
        );
        GridManager.update_indicators(page_indicators);
    }

    public void page_right() {
        AppManager.next_page();
        GridManager.populate_grid(
            grid, icon_size, font_size, item_box_width, item_box_height, grid_x, grid_y
        );
        GridManager.update_indicators(page_indicators);
    }

    // For search and filtered apps
    public Gee.ArrayList<HashMap<string, string>> filtered {
        owned get {
            var filtered = AppManager.get_filtered_apps();
            return (filtered != null) ? filtered : new Gee.ArrayList<HashMap<string, string>>();
        }
    }

    // Find app by id for folder popups and elsewhere
    public HashMap<string, string>? find_app_by_id(string app_id) {
        if (app_id == null || app_id.strip() == "")
            return null;
        return AppManager.find_app_by_id(app_id);
    }
}
