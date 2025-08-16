using Gee;
using Gtk;

public class AppManager : GLib.Object {
    private static ArrayList<HashMap<string, string>> all_apps = new ArrayList<HashMap<string, string>>();
    private static ArrayList<HashMap<string, string>> filtered_apps = new ArrayList<HashMap<string, string>>();
    private static int apps_per_page = 20; // Adjust as needed
    private static int current_page = 0;

    // Load all applications from the desktop entries backend
    public static void load_apps(int icon_size, string user_home) {
        if (all_apps != null) all_apps.clear();
        if (filtered_apps != null) filtered_apps.clear();

        // Pass a dummy icons map as required by the function signature
        var icons = new HashMap<string, Gdk.Pixbuf>();
        // Defensive: ensure out param is not null
        ArrayList<HashMap<string, string>>? loaded_apps = null;
        LightPad.Backend.DesktopEntries.enumerate_apps(icons, icon_size, user_home, out loaded_apps);
        if (loaded_apps != null) {
            all_apps = loaded_apps;
        } else {
            all_apps = new ArrayList<HashMap<string, string>>();
        }

        if (all_apps != null) {
            all_apps.sort((a, b) => {
                string aname = (a != null && a.has_key("name")) ? a["name"] : "";
                string bname = (b != null && b.has_key("name")) ? b["name"] : "";
                return GLib.strcmp(aname, bname);
            });
            foreach (var app in all_apps) {
                if (filtered_apps != null && app != null)
                    filtered_apps.add(app);
            }
        }
        current_page = 0;
    }

    // Returns a filtered, paginated list of apps for the current page
    public static ArrayList<HashMap<string, string>> get_filtered_apps() {
        int filtered_size = (filtered_apps != null) ? filtered_apps.size : 0;
        int start = current_page * apps_per_page;
        int end = (start + apps_per_page < filtered_size) ? (start + apps_per_page) : filtered_size;
        var page_apps = new ArrayList<HashMap<string, string>>();
        for (int i = start; i < end; i++) {
            if (filtered_apps != null && filtered_apps.size > i) {
                var app = filtered_apps.get(i);
                if (app != null) page_apps.add(app);
            }
        }
        return page_apps;
    }

    public static void filter_apps(string query) {
        if (filtered_apps != null) filtered_apps.clear();
        if (query.strip() == "") {
            if (all_apps != null) {
                foreach (var app in all_apps)
                    if (filtered_apps != null && app != null)
                        filtered_apps.add(app);
            }
        } else {
            if (all_apps != null) {
                foreach (var app in all_apps) {
                    if (app != null && app.has_key("name") && app["name"] != null
                        && app["name"].down().contains(query.down())) {
                        if (filtered_apps != null)
                            filtered_apps.add(app);
                    }
                }
            }
        }
        current_page = 0;
    }

    public static int get_total_pages() {
        int filtered_size = (filtered_apps != null) ? filtered_apps.size : 0;
        return (filtered_size + apps_per_page - 1) / apps_per_page;
    }

    public static void set_page(int page) {
        int total = get_total_pages();
        if (total == 0) {
            current_page = 0;
            return;
        }
        if (page < 0) page = 0;
        if (page >= total) page = total - 1;
        current_page = page;
    }

    public static void next_page() {
        set_page(current_page + 1);
    }

    public static void prev_page() {
        set_page(current_page - 1);
    }

    public static HashMap<string, string>? find_app_by_id(string app_id) {
        if (all_apps != null) {
            foreach (var app in all_apps) {
                if (app != null && app.has_key("id") && app["id"] == app_id)
                    return app;
            }
        }
        return null;
    }
}
