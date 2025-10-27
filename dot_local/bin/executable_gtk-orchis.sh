#!/bin/bash
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for dependencies
for cmd in git flatpak gsettings; do
    if ! command_exists "$cmd"; then
        echo "Error: $cmd is not installed." >&2
        exit 1
    fi
done

# Clone the Nordic theme repository into a temporary directory
TMP_DIR=$(mktemp -d)
git clone "https://github.com/vinceliuice/Orchis-theme.git" "$TMP_DIR"

# Create the themes directory if it doesn't exist
mkdir -p ~/.themes

# Copy the theme to the themes directory
cp -r "$TMP_DIR/" ~/.themes/$1

cd ~/.themes/$1

./install.sh -c dark -t purple -l --tweaks macos
