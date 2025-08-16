namespace LightPad.Backend {
using Gee;
using Gtk;
using GLib;

public class DesktopEntries : Object {
    private static string get_icon_name(Icon icon) {
        if (icon is ThemedIcon) {
            var names = ((ThemedIcon)icon).get_names();
            if (names != null && names.length > 0) return names[0];
        } else if (icon is FileIcon) {
            var file = ((FileIcon)icon).get_file();
            if (file != null)
                return file.get_path();
        }
        return (icon != null) ? icon.to_string() : "";
    }

    private static ArrayList<GMenu.TreeDirectory> get_categories() {
        var tree = new GMenu.Tree("applications.menu", GMenu.TreeFlags.INCLUDE_EXCLUDED);
        try {
            tree.load_sync();
        } catch (GLib.Error e) {
            warning("Initialization of the GMenu.Tree failed: %s", e.message);
            return new ArrayList<GMenu.TreeDirectory>();
        }
        var root = tree.get_root_directory();
        var main_directory_entries = new ArrayList<GMenu.TreeDirectory>();
        if (root != null) {
            var iter = root.iter();
            var item = iter.next();
            while (item != GMenu.TreeItemType.INVALID) {
                if (item == GMenu.TreeItemType.DIRECTORY) {
                    var dir = iter.get_directory();
                    if (dir != null)
                        main_directory_entries.add((GMenu.TreeDirectory)dir);
                }
                item = iter.next();
            }
        }
        return main_directory_entries;
    }

    private static HashSet<GMenu.TreeEntry> get_applications_for_category(GMenu.TreeDirectory category) {
        var entries = new HashSet<GMenu.TreeEntry>(
            (x) => ((GMenu.TreeEntry)x).get_desktop_file_path().hash(),
            (x, y) => ((GMenu.TreeEntry)x).get_desktop_file_path() == ((GMenu.TreeEntry)y).get_desktop_file_path()
        );
        if (category != null) {
            var iter = category.iter();
            var item = iter.next();
            while (item != GMenu.TreeItemType.INVALID) {
                switch (item) {
                    case GMenu.TreeItemType.DIRECTORY:
                        var dir = iter.get_directory();
                        if (dir != null)
                            entries.add_all(get_applications_for_category((GMenu.TreeDirectory)dir));
                        break;
                    case GMenu.TreeItemType.ENTRY:
                        var entry = iter.get_entry();
                        if (entry != null)
                            entries.add((GMenu.TreeEntry)entry);
                        break;
                    default:
                        break;
                }
                item = iter.next();
            }
        }
        return entries;
    }

    // icons: HashMap<string, Gdk.Pixbuf>
    // list: out ArrayList<HashMap<string, string>>
    public static void enumerate_apps(
        HashMap<string, Gdk.Pixbuf> icons,
        int icon_size,
        string user_home,
        out ArrayList<HashMap<string, string>> list
    ) {
        var the_apps = new HashSet<GMenu.TreeEntry>(
            (x) => ((GMenu.TreeEntry)x).get_desktop_file_path().hash(),
            (x, y) => ((GMenu.TreeEntry)x).get_desktop_file_path() == ((GMenu.TreeEntry)y).get_desktop_file_path()
        );
        var all_categories = get_categories();
        if (all_categories != null) {
            foreach (GMenu.TreeDirectory directory in all_categories) {
                if (directory != null) {
                    var this_category_apps = get_applications_for_category(directory);
                    if (this_category_apps != null) {
                        foreach (GMenu.TreeEntry this_app in this_category_apps) {
                            if (this_app != null)
                                the_apps.add(this_app);
                        }
                    }
                }
            }
        }

        var icon_theme = Gtk.IconTheme.get_default();
        list = new ArrayList<HashMap<string, string>>();

        var blacklist_file = GLib.File.new_for_path(Resources.get_blacklist_file());
        var apps_hidden = new ArrayList<string>();
        if (blacklist_file != null && blacklist_file.query_exists()) {
            try {
                var dis = new DataInputStream(blacklist_file.read());
                string? line;
                while ((line = dis.read_line(null)) != null) {
                    if (line.strip() != "")
                        apps_hidden.add(line.strip());
                }
            } catch (GLib.Error e) {
                warning("Blacklist file could not be read, no hidden apps");
            }
        }

        string[] extra_icon_dirs = {
            "/usr/share/pixmaps/",
            "/usr/share/icons/hicolor/48x48/apps/",
            user_home + "/.local/share/icons/",
            user_home + "/.local/share/pixmaps/"
        };
        string[] extensions = { ".png", ".svg", ".xpm" };

        if (the_apps != null) {
            foreach (GMenu.TreeEntry entry in the_apps) {
                if (entry == null) continue;
                var app = entry.get_app_info();
                if (app == null) continue;
                string exec_bin = "";
                if (app.get_commandline() != null && app.get_commandline() != "") {
                    exec_bin = app.get_commandline().split(" ")[0];
                }
                if (!app.get_nodisplay() &&
                    !app.get_is_hidden() &&
                    app.get_icon() != null &&
                    !apps_hidden.contains(exec_bin)
                ) {
                    var app_to_add = new HashMap<string, string>();
                    app_to_add["name"] = app.get_display_name() ?? "";
                    app_to_add["description"] = app.get_description() ?? "";
                    if (app.get_string("Terminal") == "true") {
                        app_to_add["terminal"] = "true";
                    }
                    app_to_add["command"] = app.get_commandline() ?? "";
                    app_to_add["desktop_file"] = entry.get_desktop_file_path() ?? "";
                    app_to_add["id"] = entry.get_desktop_file_path() ?? "";
                    var icon_obj = app.get_icon();
                    var app_icon = (icon_obj != null) ? get_icon_name(icon_obj) : "";
                    app_to_add["icon"] = app_icon;

                    if (!icons.has_key(app_icon)) {
                        bool found = false;
                        try {
                            if (icon_theme.has_icon(app_icon)) {
                                icons[app_icon] = icon_theme.load_icon(app_icon, icon_size, 0)
                                    .scale_simple(icon_size, icon_size, Gdk.InterpType.BILINEAR);
                                found = true;
                            }
                            else if (app_icon != null && GLib.File.new_for_path(app_icon).query_exists()) {
                                icons[app_icon] = new Gdk.Pixbuf.from_file_at_scale(app_icon, -1, icon_size, true);
                                found = true;
                            }
                            else {
                                foreach (var dir in extra_icon_dirs) {
                                    foreach (var ext in extensions) {
                                        string candidate = dir + app_icon + ext;
                                        if (GLib.File.new_for_path(candidate).query_exists()) {
                                            icons[app_icon] = new Gdk.Pixbuf.from_file_at_scale(candidate, -1, icon_size, true);
                                            found = true;
                                            break;
                                        }
                                    }
                                    if (found) break;
                                }
                            }
                            if (!found) {
                                if (icon_theme.has_icon("application-x-executable")) {
                                    icons[app_icon] = icon_theme.load_icon("application-x-executable", icon_size, 0);
                                } else {
                                    icons[app_icon] = icon_theme.load_icon("application-default-icon", icon_size, 0);
                                }
                            }
                        } catch (GLib.Error e) {
                            warning("No icon found for %s.\n", app_to_add["name"]);
                        }
                    }
                    list.add(app_to_add);
                }
            }
        }
    }
}
}
