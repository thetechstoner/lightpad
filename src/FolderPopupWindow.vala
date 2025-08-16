namespace LightPad.Frontend {

public class FolderPopupWindow : Gtk.Window {
    private int icon_size;
    private int font_size;
    private int item_box_width;
    private int item_box_height;
    private int grid_y;
    private FolderItem folder;
    private LightPadWindow main_window;

    public FolderPopupWindow(
        LightPadWindow main_window,
        int icon_size,
        int font_size,
        int item_box_width,
        int item_box_height,
        int grid_y,
        FolderItem folder
    ) {
        Object();
        this.main_window = main_window;
        this.icon_size = icon_size;
        this.font_size = font_size;
        this.item_box_width = item_box_width;
        this.item_box_height = item_box_height;
        this.grid_y = grid_y;
        this.folder = folder;
        this.set_type_hint(Gdk.WindowTypeHint.DIALOG);
        this.set_decorated(false);
        this.set_resizable(false);
        this.set_border_width(12);

        var grid = new Gtk.Grid();
        grid.set_row_spacing(6);
        grid.set_column_spacing(6);

        int row = 0;
        foreach (var app_id in folder.apps) {
            var app_info = main_window.find_app_by_id(app_id);
            if (app_info == null)
                continue;

            var item = new AppItem(
                app_info,
                icon_size,
                font_size,
                item_box_width,
                item_box_height
            );

            var remove_button = new Gtk.Button.from_icon_name("list-remove-symbolic", Gtk.IconSize.BUTTON);
            // Capture the current app_id for the lambda
            remove_button.clicked.connect(() => {
                FolderManager.remove_app_from_folder(folder.folder_name, app_id);
                this.destroy();
            });

            grid.attach(item, 0, row, 1, 1);
            grid.attach(remove_button, 1, row, 1, 1);
            row++;
        }

        this.add(grid);
        this.show_all();
    }
}

}
