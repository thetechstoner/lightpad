using Gee;
using Gtk;
using Json;
using LightPad.Frontend;

public class FolderManager : GLib.Object {
    private static ArrayList<FolderItem> folders = new ArrayList<FolderItem>();
    private static string config_path = Resources.get_config_dir() + "/folders.json";

    public static ArrayList<FolderItem> load_existing_folders() {
        if (folders != null) folders.clear();
        string content = "";
        try {
            if (config_path == null || config_path.strip() == "" ||
                !GLib.FileUtils.get_contents(config_path, out content)) {
                return folders;
            }
        } catch (GLib.FileError e) {
            warning("Failed to read config file: %s", e.message);
            return folders;
        }
        if (content.strip() != "") {
            try {
                var parser = new Json.Parser();
                parser.load_from_data(content, -1);
                var root_node = parser.get_root();
                if (root_node != null && root_node.get_node_type() == Json.NodeType.ARRAY) {
                    var root = root_node.get_array();
                    foreach (var node in root.get_elements()) {
                        var obj = node.get_object();
                        var folder = new FolderItem(
                            new Gee.HashMap<string, string>(),
                            48, 14, 96, 84
                        );
                        folder.folder_name = obj.get_string_member("name");
                        if (obj.has_member("apps")) {
                            var apps_array = obj.get_array_member("apps");
                            if (apps_array != null) {
                                foreach (var app_node in apps_array.get_elements()) {
                                    if (folder.apps != null)
                                        folder.apps.add(app_node.get_string());
                                }
                            }
                        }
                        if (folders != null)
                            folders.add(folder);
                    }
                }
            } catch (Error e) {
                warning("Failed to load folders: %s", e.message);
            }
        }
        return folders;
    }

    public static void save_all_folders() {
        var arr = new Json.Array();
        if (folders != null) {
            foreach (var folder in folders) {
                var obj = new Json.Object();
                obj.set_string_member("name", folder.folder_name);
                var apps_arr = new Json.Array();
                if (folder.apps != null) {
                    foreach (var appid in folder.apps) {
                        apps_arr.add_string_element(appid);
                    }
                }
                obj.set_array_member("apps", apps_arr);
                arr.add_object_element(obj);
            }
        }
        var gen = new Json.Generator();
        var node = new Json.Node(Json.NodeType.ARRAY);
        node.set_array(arr);
        gen.set_root(node);
        try {
            if (config_path != null && config_path.strip() != "")
                gen.to_file(config_path);
        } catch (Error e) {
            warning("Failed to save folders: %s", e.message);
        }
    }

    public static void add_app_to_folder(string folder_name, string app_id) {
        var folder = get_folder_by_name(folder_name);
        if (folder == null) {
            folder = new FolderItem(new Gee.HashMap<string, string>(), 48, 14, 96, 84);
            folder.folder_name = folder_name;
            if (folders != null) folders.add(folder);
        }
        if (folder.apps != null && !folder.apps.contains(app_id)) {
            folder.apps.add(app_id);
            save_all_folders();
        }
    }

    public static void remove_app_from_folder(string folder_name, string app_id) {
        var folder = get_folder_by_name(folder_name);
        if (folder == null) return;
        if (folder.apps != null) {
            folder.apps.remove(app_id);
            if (folder.apps.size == 0 && folders != null) {
                folders.remove(folder);
            }
        }
        save_all_folders();
    }

    public static FolderItem? get_folder_by_name(string name) {
        if (folders != null) {
            foreach (var folder in folders) {
                if (folder.folder_name == name) return folder;
            }
        }
        return null;
    }

    public static ArrayList<FolderItem> get_folders() {
        return folders;
    }
}
