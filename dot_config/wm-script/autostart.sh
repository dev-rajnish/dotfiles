#!/usr/bin/env bash
# Autostart script for Niri window manager session

# --- Background Services ---
# Status bar and notification
# waybar &

swaync &
# Clipboard manager (text & image store)
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &

# --- Autostart Applications ---
kitty
