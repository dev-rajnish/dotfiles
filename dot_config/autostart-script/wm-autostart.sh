#!/usr/bin/env bash
# Autostart script for Niri window manager session

# --- D-Bus & Systemd User Environment Sync (Required for File Picker & Portals) ---
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY XDG_SESSION_TYPE &
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY XDG_SESSION_TYPE &

# --- Background Services ---
# Clipboard manager (text & image store)
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &

# --- Autostart Applications ---
kitty &
