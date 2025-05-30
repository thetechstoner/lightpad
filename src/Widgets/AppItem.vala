/*
* Copyright (c) 2011-2020 LightPad
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Juan Pablo Lozano <libredeb@gmail.com>
*/

namespace LightPad.Frontend {

    public class AppItem : Gtk.EventBox {
    
        private Gdk.Pixbuf icon;
        private LightPad.Frontend.Color prominent;
        private string label;
        private Gtk.Box wrapper;
        private double font_size;
        private int icon_size;

        const int FPS = 24;
        const int DURATION = 200;
        const int RUN_LENGTH = (int)(DURATION/FPS); // Total number of frames
        private int current_frame = 1; // Run length, in frames

        public AppItem (int size, double font_size, int box_width, int box_height) {
            this.icon_size = size;
            this.font_size = font_size;

            // EventBox Properties, a box that show up on hover
            this.set_visible_window (false);
            this.can_focus = true;
            // Height is also the padding between icon and label's height
            this.set_size_request (box_width, box_height);

            // VBox properties
            this.wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            this.wrapper.draw.connect (this.draw_icon);
            this.add (this.wrapper);

            // Focused signals
            this.draw.connect (this.draw_background);
            this.focus_in_event.connect ( () => { this.focus_in (); return true; } );
            this.focus_out_event.connect ( () => { this.focus_out (); return true; } );
        }
        
        public void change_app (Gdk.Pixbuf new_icon, string new_name, string new_tooltip) {
            this.current_frame = 1;

            // Icon
            this.icon = new_icon;
            this.prominent = LightPad.Frontend.Utilities.average_color (this.icon);

            // Label
            this.label = new_name;

            // Tooltip
            this.set_tooltip_text (new_tooltip);

            // Redraw
            this.wrapper.queue_draw ();
        }
        
        public new void focus_in () {
            GLib.Timeout.add (((int)(1000/FPS)), () => {
                if (this.current_frame >= RUN_LENGTH || !this.has_focus) {
                    current_frame = 1;
                    return false; // Stop animation
                }

                queue_draw ();
                this.current_frame++;
                return true;
            });
        }
        
        public new void focus_out () {
            GLib.Timeout.add (((int)(1000/FPS)), () => {
                if (this.current_frame >= RUN_LENGTH || this.has_focus) {
                    current_frame = 1;
                    return false; // Stop animation
                }

                queue_draw ();
                this.current_frame++;
                return true;
            });
        }
        
        private bool draw_icon (Gtk.Widget widget, Cairo.Context ctx) {
            Gtk.Allocation size;
            widget.get_allocation (out size);

            // Draw icon
            Gdk.cairo_set_source_pixbuf (ctx, this.icon, size.x + ((this.icon.width - size.width) / -2.0), size.y);
            ctx.paint ();

            // Truncate text
            Cairo.TextExtents extents;
            ctx.select_font_face ("Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
            ctx.set_font_size (this.font_size);
            LightPad.Frontend.Utilities.truncate_text (ctx, size, 10, this.label, out this.label, out extents);

            // Draw text shadow
            ctx.move_to ((size.x + size.width/2 - extents.width/2) + 1, (size.y + size.height - 10) + 1);
            ctx.set_source_rgba (0.0, 0.0, 0.0, 0.8);
            ctx.show_text (this.label);

            // Draw normal text
            ctx.set_source_rgba (1.0, 1.0, 1.0, 1.0);
            ctx.move_to (size.x + size.width/2 - extents.width/2, size.y + size.height - 10);
            ctx.show_text (this.label);

            return false;
        }

        private bool draw_background (Gtk.Widget widget, Cairo.Context ctx) {
            Gtk.Allocation size;
            widget.get_allocation (out size);

            double progress;
            if (this.current_frame > 1) {
                progress = (double)RUN_LENGTH/(double)this.current_frame;
            } else {
            progress = 1;
            }

            if (this.has_focus) {
                double dark = 0.32;
                var gradient = new Cairo.Pattern.rgba (this.prominent.R * dark, this.prominent.G * dark, this.prominent.B * dark, 0.8);
                ctx.set_source (gradient);
                LightPad.Frontend.Utilities.draw_rounded_rectangle (ctx, 10, 0.5, size);
                ctx.fill ();
            }  else  {
            if (this.current_frame > 1) {
            var gradient = new Cairo.Pattern.rgba (0.0, 0.0, 0.0, 0.0);

            ctx.set_source (gradient);
            LightPad.Frontend.Utilities.draw_rounded_rectangle (ctx, 10, 0.5, size);
            ctx.fill ();
                }
            }
    
            return false;
        }

    }

}
