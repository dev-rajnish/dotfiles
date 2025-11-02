#!/usr/bin/env bash
# Force Papirus icon theme system-wide (user-level)
# Works for GTK, Qt, and XDG environments.

set -e

ICON_THEME="Papirus"
ENV_DIR="$HOME/.config/environment.d"
ENV_FILE="$ENV_DIR/papirus-icon.conf"

# Ensure the Papirus icon theme is installed
if ! grep -iq "$ICON_THEME" <(ls /usr/share/icons 2>/dev/null); then
    echo "Papirus icon theme not found. Installing..."
    if command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y papirus-icon-theme
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y papirus-icon-theme
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm papirus-icon-theme
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y papirus-icon-theme
    else
        echo "Please install 'papirus-icon-theme' manually."
        exit 1
    fi
fi

# Create environment.d folder if missing
mkdir -p "$ENV_DIR"

# Write environment variables for Papirus
cat > "$ENV_FILE" <<EOF
# Automatically generated Papirus icon configuration
# Forces Papirus icon theme for all GTK/Qt/XDG applications

# XDG standard
XDG_CURRENT_DESKTOP=\${XDG_CURRENT_DESKTOP:-generic}
XDG_ICON_THEME="$ICON_THEME"

# GTK configuration
GTK_ICON_THEME_NAME="$ICON_THEME"
GTK_THEME="$ICON_THEME"

# Qt configuration
QT_QPA_PLATFORMTHEME="qt5ct"
QT_ICON_THEME="$ICON_THEME"
QT_STYLE_OVERRIDE="fusion"

# Other compatibility
XCURSOR_THEME="$ICON_THEME"
XCURSOR_SIZE="24"

EOF

echo "✅ Environment variables written to: $ENV_FILE"

# Apply for current session
export XDG_ICON_THEME="$ICON_THEME"
export GTK_ICON_THEME_NAME="$ICON_THEME"
export GTK_THEME="$ICON_THEME"
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_ICON_THEME="$ICON_THEME"
export QT_STYLE_OVERRIDE="fusion"
export XCURSOR_THEME="$ICON_THEME"
export XCURSOR_SIZE="24"

# Update GTK 2 & 3 settings
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.gtkrc-2.0.d"
echo "[Settings]" > "$HOME/.config/gtk-3.0/settings.ini"
echo "gtk-icon-theme-name=$ICON_THEME" >> "$HOME/.config/gtk-3.0/settings.ini"
cp "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
echo "gtk-icon-theme-name=\"$ICON_THEME\"" > "$HOME/.gtkrc-2.0"

# Update LXQt or Qt5ct configs if present
if [ -d "$HOME/.config/qt5ct" ]; then
    sed -i "s/^icon_theme=.*/icon_theme=$ICON_THEME/" "$HOME/.config/qt5ct/qt5ct.conf" 2>/dev/null || true
fi
if [ -d "$HOME/.config/lxqt" ]; then
    sed -i "s/^icon_theme=.*/icon_theme=$ICON_THEME/" "$HOME/.config/lxqt/lxqt.conf" 2>/dev/null || true
fi

echo "✅ Papirus icon theme applied everywhere."
echo "🔁 Log out and back in (or reboot) for environment.d changes to take full effect."
