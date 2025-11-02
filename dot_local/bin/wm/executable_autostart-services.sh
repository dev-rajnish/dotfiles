#!/bin/bash

brightnessctl s 70% &

~/.local/bin/wm/random-wallpaper.sh &

sleep 2

swayosd-server &

## PANEL
#waybar
#waybar &
#~/.local/bin/panel.sh &



# Clipboard: history nwg-clipman
sleep 1
~/.local/bin/wm/clipboard.sh &
#hypridle
#hypridle

# Display

# Cursor


# Inputs
sleep 1
fcitx5 &
sleep 1
udiskie &

# Core components (authentication, lock screen, notification daemon)

#gnome-keyring-daemon --start --components=secrets
sleep 2
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1

sleep 1

dbus-update-activation-environment --all
sleep 0.1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP # Some fix idk
sleep 0.1 && dbus-update-activation-environment --systemd DISPLAY XDG_CURRENT_DESKTOP # Some fix idk
sleep 1
/usr/lib/xdg-desktop-portal &
