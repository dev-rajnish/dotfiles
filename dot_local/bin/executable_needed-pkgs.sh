    #!/bin/bash
    #set -e

    # Make script location independent
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null &&pwd )

    echo "Syncing , updating and installing reflector... "
    sudo pacman -Syu --needed reflector --noconfirm

    echo "Backing up mirrorlist... "
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

    echo "Setting up reflector... "
    sudo reflector --verbose --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

    echo "Installing required pkgs... "
    xargs -a "$SCRIPT_DIR/pkgs/all.list" sudo pacman -Syu --needed --noconfirm

    if ! command -v yay &> /dev/null; then
        echo "Installing yay..."
        sudo pacman -S --needed git base-devel
        TMP_DIR=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$TMP_DIR"
        (cd "$TMP_DIR" && makepkg -si --noconfirm)
        rm -rf "$TMP_DIR"
    else
        echo "yay is already installed."
    fi

    echo "Installing aur pkgs... "
    xargs -a "$SCRIPT_DIR/pkgs/all-aur.list" yay -Syu --needed --noconfirm
