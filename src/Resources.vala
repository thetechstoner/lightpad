namespace Resources {

public const string PROJECT_NAME = "lightpad";

public string get_config_dir() {
    string home = GLib.Environment.get_variable("HOME") ?? "";
    return GLib.Path.build_filename(home, "." + PROJECT_NAME);
}

public string get_config_file() {
    return GLib.Path.build_filename(get_config_dir(), "config");
}

public string get_blacklist_file() {
    return GLib.Path.build_filename(get_config_dir(), "blacklist");
}

public string get_background_png() {
    return GLib.Path.build_filename(get_config_dir(), "background.png");
}

public string get_background_jpg() {
    return GLib.Path.build_filename(get_config_dir(), "background.jpg");
}

public string get_resource_file(string filename) {
    return GLib.Path.build_filename(get_config_dir(), filename);
}

}
