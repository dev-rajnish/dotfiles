pkill waypaper 

# pkill waybar && waybar &
# sed -i "s|^[[:space:]]*path = .*|    path = $1|"\
#   ~/.config/hypr/hyprlock.conf
#restart lock session

#pkill hyprlock && hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1'
matugen -t scheme-tonal-spot image $1
bash ~/.local/bin/remove_hex_prefix.sh
swaync-client -rs
bash ~/.local/bin/panel-kill.sh
bash ~/.local/bin/panel-open.sh
