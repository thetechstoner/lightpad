using Gtk;
using Gdk;

namespace LightPad.Frontend {

public class Application : Gtk.Application {
    public Application () {
        Object (
            application_id: "org.libredeb.lightpad",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        if (this.get_windows().length() == 0) {
            var window = new LightPadWindow ();
            window.application = this;
            window.show_all ();
        }
    }
}

public static int main (string[] args) {
    Gtk.init (ref args);

    // Load CSS
    string css_file = Config.PACKAGE_SHAREDIR +
        "/" + Config.PROJECT_NAME +
        "/" + "application.css";
    var css_provider = new Gtk.CssProvider ();
    // Gtk.CssProvider.load_from_path does NOT throw in modern Vala/GTK
try {
    css_provider.load_from_path(css_file);
} catch (GLib.Error e) {
    warning("Could not load CSS file: %s", e.message);
}
Gtk.StyleContext.add_provider_for_screen(
    Gdk.Screen.get_default(),
    css_provider,
    Gtk.STYLE_PROVIDER_PRIORITY_USER
);

    // Use your Application class
    var app = new Application();

    int status = app.run (args);
    return status;
}

}
