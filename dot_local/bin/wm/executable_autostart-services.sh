#!/bin/bash

swaync &
waypaper --random
swww-daemon &
swayosd-server &

## PANEL
#waybar
#waybar &
~/.local/bin/panel.sh



# Clipboard: history nwg-clipman
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &

#hypridle
#hypridle

# Display
brightnessctl s 80%

# Cursor


# Inputs
fcitx5 &
udiskie &

# Core components (authentication, lock screen, notification daemon)
gnome-keyring-daemon --start --components=secrets

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1

dbus-update-activation-environment --all
sleep 0.1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP # Some fix idk
sleep 0.1 && dbus-update-activation-environment --systemd DISPLAY XDG_CURRENT_DESKTOP # Some fix idk

/usr/lib/xdg-desktop-portal &
