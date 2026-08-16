#!/usr/bin/env bash
# Autostart script for Niri window manager session

# --- GNOME Keyring Daemon & Secret Service ---
# Start Keyring components if not already started by PAM
eval $(gnome-keyring-daemon --start --components=secrets,ssh,pkcs11 2>/dev/null)
export SSH_AUTH_SOCK
export GNOME_KEYRING_CONTROL

# --- D-Bus & Systemd User Environment Sync (Required for Portals, File Picker & Keyring) ---
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY XDG_SESSION_TYPE SSH_AUTH_SOCK GNOME_KEYRING_CONTROL &
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY XDG_SESSION_TYPE SSH_AUTH_SOCK GNOME_KEYRING_CONTROL &

# --- Background Services ---
# Clipboard manager (text & image store)
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &

# --- Autostart Applications ---
kitty &

# Optional: Launch default distrobox container if present
if command -v distrobox >/dev/null 2>&1 && distrobox list 2>/dev/null | grep -q "arch"; then
  distrobox enter arch &
fi
