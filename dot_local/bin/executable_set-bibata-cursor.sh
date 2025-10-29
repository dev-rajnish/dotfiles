#!/usr/bin/env bash
# Sets Bibata-Modern-Ice cursor theme on Linux
# Works with X11 or Wayland, independent of DE (GNOME, KDE, Sway, Hyprland, etc.)
# Adds environment variables in ~/.config/environment.d/cursor.conf

set -e

CURSOR_THEME="Bibata-Modern-Ice"
XCURSOR_SIZE="${XCURSOR_SIZE:-32}"
CURSOR_DIR_SYSTEM="/usr/share/icons/$CURSOR_THEME"
CURSOR_DIR_USER="$HOME/.icons/$CURSOR_THEME"

echo "🔍 Checking for $CURSOR_THEME installation..."

# 1️⃣ Ensure the theme is installed
if [ ! -d "$CURSOR_DIR_SYSTEM" ] && [ ! -d "$CURSOR_DIR_USER" ]; then
  echo "⚠️  Cursor theme not found. Installing Bibata-Modern-Ice..."

  if command -v git >/dev/null 2>&1; then
    git clone --depth 1 https://github.com/ful1e5/Bibata_Cursor.git /tmp/Bibata_Cursor
    mkdir -p ~/.icons
    cp -r /tmp/Bibata_Cursor/Bibata-Modern-Ice ~/.icons/
    rm -rf /tmp/Bibata_Cursor
  else
    echo "❌ 'git' not found. Please install it or manually install Bibata-Modern-Ice."
    exit 1
  fi
fi

# 2️⃣ Update per-user configuration
echo "🧩 Setting cursor theme to $CURSOR_THEME..."

# Set up .icons/default for legacy apps
mkdir -p ~/.icons/default
cat > ~/.icons/default/index.theme <<EOF
[Icon Theme]
Inherits=$CURSOR_THEME
EOF

# Set XDG config version (for modern compositors)
mkdir -p ~/.config/icons/default
cat > ~/.config/icons/default/index.theme <<EOF
[Icon Theme]
Inherits=$CURSOR_THEME
EOF

# 3️⃣ Create environment.d configuration
mkdir -p ~/.config/environment.d
cat > ~/.config/environment.d/cursor.conf <<EOF
XCURSOR_THEME=$CURSOR_THEME
XCURSOR_SIZE=$XCURSOR_SIZE
QT_CURSOR_THEME=$CURSOR_THEME
GTK_CURSOR_THEME=$CURSOR_THEME
EOF

echo "💾 Created ~/.config/environment.d/cursor.conf"

# 4️⃣ X11 immediate application
if command -v xset >/dev/null 2>&1; then
  echo "🖱️  Applying cursor for X11 session..."
  xsetroot -cursor_name left_ptr 2>/dev/null || true
fi

# 5️⃣ Optional system-wide installation
if [ "$1" = "--system" ]; then
  echo "🛠️  Applying system-wide..."
  sudo mkdir -p /usr/share/icons/default
  echo "[Icon Theme]
Inherits=$CURSOR_THEME" | sudo tee /usr/share/icons/default/index.theme >/dev/null

  sudo mkdir -p /etc/environment.d
  echo "XCURSOR_THEME=$CURSOR_THEME
XCURSOR_SIZE=$XCURSOR_SIZE
QT_CURSOR_THEME=$CURSOR_THEME
GTK_CURSOR_THEME=$CURSOR_THEME" | sudo tee /etc/environment.d/cursor.conf >/dev/null
fi

echo "✅ Cursor theme set to '$CURSOR_THEME'!"
echo "ℹ️  Log out and back in (or reboot) to apply changes everywhere."
