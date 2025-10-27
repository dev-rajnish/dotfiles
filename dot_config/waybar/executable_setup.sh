#!/bin/bash

#1 download just pkg_name folder from monarchy/dotfiles/$pkg_name in temp/

# 2 move that folder to ~/.config/$pkg_name if folder exist backup name=$pkg_name.before-monarchy

# 3 check for dependencies needed for $pkg_name
## dependencies are waybar, fuzzel, hyprland, wl-clipboard, nwg-clipman,\
##swaync, hyprshot, waypaper, swww, hyprpicker, pavucontrol, wlogout \
## wallust, hyprlock

#### ==> code
#set -x

NAME="waybar"
REPO="https://github.com/dev-rajnish/monarchy.git"
TEMP="/tmp/$NAME"
DEST="$HOME/.config/$NAME"
#
echo ` 1. Clone only waybar folder from repo (sparse clone)`
if [ -d "$TEMP" ]; then
	rm -rf "$TEMP"
fi

#
echo "2. Cloning config of $NAME ..."
git clone --depth 1 --filter=blob:none --sparse "$REPO" "$TEMP"
cd "$TEMP"
git sparse-checkout set dotfiles/$NAME

#
echo "3. Setting up ~/.config/$NAME..."
if [ -d "$DEST" ]; then
	rm -rf "${DEST}.before-monarchy"
	mv "$DEST" "${DEST}.before-monarchy"
	echo "→ Backed up existing $DEST config to ~/.config/$DEST.before-monarchy"
fi
mv "$TEMP/dotfiles/$NAME" "$DEST"

#
echo "4. Checking dependencies..."
REQUIRED_PKGS=(
	waybar fuzzel hyprland wl-copy nwg-clipman swaync waypaper
	swww hyprland hyprpicker hyprlock hypridle hyprshot
	pavucontrol wlogout wallust brightnessctl wpctl playerctl
)
MISSING_PKGS=()
for pkg in "${REQUIRED_PKGS[@]}"; do
	if ! command -v "$pkg" >/dev/null 2>&1; then
		MISSING_PKGS+=("$pkg")
	fi
done

#
if [ "${#MISSING_PKGS[@]}" -gt 0 ]; then
	echo "⚠️  Missing packages: ${MISSING_PKGS[*]}"
	echo "Please install them manually or via your package manager (YAY/pacman)"
else
	echo "✅ All dependencies found"
fi

#
echo "✅ $NAME setup complete under 'monarchy'"
#
exit
