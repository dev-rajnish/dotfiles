#!/bin/bash
pkill waypaper 

bash ~/.local/bin/remove_hex_prefix.sh

#swaync-client -rs

bash ~/.local/bin/wm/panel-kill.sh

bash ~/.local/bin/wm/panel-open.sh

rm ~/.config/yazi/theme.toml-*
rm ~/.config/yazi/keymap.toml-*
rm ~/.config/yazi/yazi.toml-*
chezmoi re-add ~/.config/
chezmoi re-add ~/.local/
# pkill waybar && waybar &
# sed -i "s|^[[:space:]]*path = .*|    path = $1|"\
#   ~/.config/hypr/hyprlock.conf
#restart lock session

#pkill hyprlock && hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1'

