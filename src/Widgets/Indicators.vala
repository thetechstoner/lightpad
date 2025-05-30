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

    public class Indicators : Gtk.HBox {
    
        // Animation constants
        const int FPS = 60;
        private int animation_duration;
        private int animation_frames; // total number of frames
        private int current_frame = 1;
        private uint animation_loop_id = 0;
        private bool animation_active = false;

        // Signals
        public signal void child_activated ();

        // Properties
        public new GLib.List<Gtk.Widget> children;
        public int active = -1;
        private int old_active = -1;
        private int skip_flag = 0;
        
        public Indicators () {
            this.homogeneous = false;
            this.spacing = 0;
        }

        public void append (string thelabel) {
            var indicator = new Gtk.EventBox ();
            indicator.set_visible_window (false);

            var label = new Gtk.Label (thelabel);
            label.get_style_context ().add_class ("indicator_label");

            // make sure the child widget is added with padding
            label.set_halign (Gtk.Align.CENTER);
            label.set_valign (Gtk.Align.CENTER);
            label.set_margin_top (5);
            label.set_margin_bottom (5);
            label.set_margin_start (15);
            label.set_margin_end (15);
            indicator.add (label);
            this.children.append (indicator);
            
            this.draw.connect (draw_background);
            indicator.button_release_event.connect( () => {
                this.set_active (this.children.index (indicator));
                return true;
            });

            this.pack_start (indicator, false, false, 0);
        }
        
        public void set_active_no_signal (int index) {
            int pages_length = (int) this.children.length ();
            // make sure the requested active item is in the children list
            if (index <= (pages_length - 1)) {
                this.old_active = this.active;
                this.active = index;
                this.change_focus ();
            }

        }

        public void set_active (int index) {
            skip_flag++;
            this.set_active_no_signal (index);
            if (skip_flag > 1) { // avoid activating a page "0" that does not exist
                this.child_activated (); // send signal
            }
        }
        
        public void change_focus () {
            //make sure no other animation is running, if so kill it with fire
            if (animation_active) {
                GLib.Source.remove (animation_loop_id);
                end_animation ();
            }

            /* definie animation_duration, base is 250 millisecionds for which
               50 ms is added for each item to span */
            this.animation_duration = 240;
            int difference = (this.old_active - this.active).abs ();
            this.animation_duration += (int) (Math.pow (difference, 0.5) * 80);
            //this.animation_frames = (int)((double) animation_duration / 1000 * FPS);
            this.animation_frames = 2;

            // initial conditions for animation.
            this.current_frame = 0;
            this.animation_active = true;

            this.animation_loop_id = GLib.Timeout.add (((int)(1000 / FPS)), () => {
                if (this.current_frame >= this.animation_frames) {
                    end_animation ();
                    return false; // stop animation
                }

                this.current_frame++;
                this.queue_draw ();
                return true;
            });
        }

        private void end_animation () {
            animation_active = false;
            current_frame = 0;
        }

        protected bool draw_background (Gtk.Widget widget, Cairo.Context ctx) {
            Gtk.Allocation size;
            widget.get_allocation (out size);
    
            double d = (double) this.animation_frames;
            double t = (double) this.current_frame;
            double progress = ((t = t/d - 1) * t * t * t * t + 1);

            Gtk.Allocation size_old, size_new;
            this.get_children().nth_data(this.old_active).get_allocation(out size_old);
            this.get_children().nth_data(this.active).get_allocation(out size_new);

            double x = size_old.x + (size_new.x - (double) size_old.x) * progress;
            double y = size_old.y + (size_new.y - (double) size_old.y);
            double width = size_old.width + (size_new.width - (double) size_old.width) * progress;
            double height = size_old.height + (size_new.height - (double) size_old.height);

            double offset = 2.0;
            double radius = 6.0;

            ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0);
            ctx.move_to(x + radius, size.y + offset);
            ctx.arc(x + width/2, y + height/2, radius, 0, Math.PI * 2);
            ctx.fill();

            return false;
        }


    }

}
