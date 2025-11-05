#!/bin/bash
#
# Description: This script installs the Papirus icon theme and applies it across
#              GTK (2/3/4) and Qt (5/6) applications in the user space.
#
# Usage: ./set-papirus-icons.sh
#

# Exit immediately if a command exits with a non-zero status.
set -e

# --- INSTALLATION ---
echo "Installing Papirus icon theme via yay..."
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please install it first."
    exit 1
fi
# Use --noconfirm to prevent the script from pausing for user input.
yay -S --noconfirm papirus-icon-theme
echo "Papirus icon theme successfully installed."
echo "----------------------------------------"


# --- GTK CONFIGURATION ---
echo "Setting icon theme for GTK applications..."

# Set theme for GTK 3/4 using GSettings (modern method)
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
    echo "GTK 3/4 theme set via GSettings."
else
    echo "GSettings not found, skipping GTK 3/4 configuration."
fi

# Set theme for GTK2 by modifying .gtkrc-2.0
GTK2_CONFIG="$HOME/.gtkrc-2.0"
# Remove any existing icon theme setting to avoid duplicates
if [ -f "$GTK2_CONFIG" ]; then
    sed -i '/gtk-icon-theme-name/d' "$GTK2_CONFIG"
fi
# Add the new setting
echo 'gtk-icon-theme-name="Papirus"' >> "$GTK2_CONFIG"
echo "GTK2 theme set in $GTK2_CONFIG"
echo "----------------------------------------"


# --- QT CONFIGURATION ---
echo "Setting icon theme for Qt applications (qt5ct/qt6ct)..."

# Configure Qt5 via qt5ct
QT5_CONFIG="$HOME/.config/qt5ct/qt5ct.conf"
if [ -f "$QT5_CONFIG" ]; then
    # Ensure we are editing under the [Appearance] section
    if grep -q "^\[Appearance\]" "$QT5_CONFIG"; then
        sed -i "/^\[Appearance\]/,/^\[/ s/^icon_theme=.*/icon_theme=Papirus/" "$QT5_CONFIG"
        echo "Qt5 theme updated in $QT5_CONFIG"
    fi
else
    echo "Qt5 settings file not found, skipping: $QT5_CONFIG"
fi

# Configure Qt6 via qt6ct
QT6_CONFIG="$HOME/.config/qt6ct/qt6ct.conf"
if [ -f "$QT6_CONFIG" ]; then
    # Ensure we are editing under the [Appearance] section
    if grep -q "^\[Appearance\]" "$QT6_CONFIG"; then
        sed -i "/^\[Appearance\]/,/^\[/ s/^icon_theme=.*/icon_theme=Papirus/" "$QT6_CONFIG"
        echo "Qt6 theme updated in $QT6_CONFIG"
    fi
else
    echo "Qt6 settings file not found, skipping: $QT6_CONFIG"
fi

echo "----------------------------------------"
echo "✅ All done!"
echo "The Papirus icon theme has been set."
echo "You may need to log out and log back in for all changes to take effect."
