#!/bin/bash
#brightness 
## set brightness.default restore it 

#wallpaper
## set img.default restore it

#panel
## linked with wallpaper restore

#notification
## fnott started with systemd service

#volume-control
## set with pactl

#player-control
## set with playerctl

#clipboard
## wl-clipboard,cliphist,nwg-clipman

#auth
## lxqt auth,gnome auth

#portal
## xdg-desktop-portal,xdg-desktop-portal-wlr,xdg-desktop-portal-lxqt

#idle-inhabrter
## swayidle

#lockscreen
## swaylock

#session-menu
wlogout

#launcher
## fuzzel,maybe walker

#terminal
## fnott

#env
## with systemd environment.d




brightnessctl s 70% &

~/.local/bin/de/wallpaper/wallpaper.sh &

sleep 2
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
# Core components (authentication, lock screen, notification daemon)

#gnome-keyring-daemon --start --components=secrets
sleep 2
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1

sleep 1

dbus-update-activation-environment --all
sleep 0.1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP # Some fix idk
sleep 0.1 && dbus-update-activation-environment --systemd DISPLAY XDG_CURRENT_DESKTOP # Some fix idk
sleep 1
/usr/lib/xdg-desktop-portal-lxqt &
