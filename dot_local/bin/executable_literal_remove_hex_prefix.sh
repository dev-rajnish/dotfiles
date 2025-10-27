#!/bin/bas
sed -i 's/#\([0-9a-fA-F]\{6\}\)/\1/g'  /home/rsh/.config/refine/set_color_scheme.fish
cp  /home/rsh/.config/refine/set_color_scheme.fish ~/.config/fish/functions/set_color_scheme.fish

