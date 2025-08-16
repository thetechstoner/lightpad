using Gtk;
using Gee;
using LightPad.Frontend; // For AppItem and Indicators

public class GridManager : GLib.Object {
    public static void populate_grid(
        Gtk.Grid grid,
        int icon_size,
        int font_size,
        int item_box_width,
        int item_box_height,
        int grid_x,
        int grid_y
    ) {
        // Remove all existing children from the grid
        grid.foreach((widget) => { grid.remove(widget); });

        var apps = AppManager.get_filtered_apps();
        var folders = FolderManager.load_existing_folders();
        var children = new ArrayList<Gtk.Widget>();
        var apps_in_folders = new HashSet<string>();

        // Add folders and collect app IDs that are already in folders
        if (folders != null) {
            foreach (var folder in folders) {
                if (folder != null) {
                    children.add(folder);
                    if (folder.apps != null) {
                        foreach (var appid in folder.apps) {
                            if (appid != null)
                                apps_in_folders.add(appid);
                        }
                    }
                }
            }
        }

        // Add app items that are not already in folders
        if (apps != null) {
            foreach (var app in apps) {
                if (app != null && app.has_key("id") && app["id"] != null && !apps_in_folders.contains(app["id"])) {
                    var item = new AppItem(
                        app,
                        icon_size,
                        font_size,
                        item_box_width,
                        item_box_height
                    );
                    children.add(item);
                }
            }
        }

        // Attach all widgets to the grid, filling by rows (grid_x columns)
        int children_size = (children != null) ? children.size : 0;
        for (int i = 0; i < children_size; i++) {
            int col = i % grid_x;
            int row = i / grid_x;
            if (children.get(i) != null)
                grid.attach(children.get(i), col, row, 1, 1);
        }
    }

    public static void update_grid(Gtk.Grid grid,
        int icon_size,
        int font_size,
        int item_box_width,
        int item_box_height,
        int grid_x,
        int grid_y
    ) {
        // Repopulate the grid with current data
        populate_grid(grid, icon_size, font_size, item_box_width, item_box_height, grid_x, grid_y);
        grid.show_all();
    }

    public static void search(string query, Gtk.Grid grid,
        int icon_size,
        int font_size,
        int item_box_width,
        int item_box_height,
        int grid_x,
        int grid_y
    ) {
        AppManager.filter_apps(query);
        update_grid(grid, icon_size, font_size, item_box_width, item_box_height, grid_x, grid_y);
    }

    public static void update_indicators(Indicators indicators) {
        int total_pages = AppManager.get_total_pages();
        indicators.clear();
        for (int i = 0; i < total_pages; i++) {
            indicators.append("⬤");
        }
        indicators.set_active(0);
    }
}
