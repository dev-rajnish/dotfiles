curl

sudo pacman -Syu curl git vim chezmoi

iwd

iwctl

rfkill list

sudo rfkill unblock all

sudo pacman -Syu curl git vim chezmoi

sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com

sudo pacman-key --lsign-key 3056513887B78AEB

sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'

sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

echo [chaotic-aur] | sudo tee -a  /etc/pacman.conf ; bat /etc/pacman.conf

echo Include = /etc/pacman.d/chaotic-mirrorlist | sudo tee -a  /etc/pacman.conf ; bat /etc/pacman.conf

sudo pacman -Syu

sudo pacman -Syu niri-git

chezmoi init --apply dev-rajnish

sudo pacman -Syu --needed git curl vim fish bat starship fastfetch chezmoi fuzzel xdg-utils yazi neovim wl-clipboard nwg-clipman cliphist geany qutebrowser links lynx w3m netsurf qps kmonad  --noconfirm

getnf -i VictorMono, RobotoMono, Noto,NerdFontsSymbolsOnly, JetBrainsMono, GeistMono

git clone https://github.com/dev-rajnish/walls.git

sudo pacman -Syu --needed pfetch
pfetch 
sudo pacman -Syu --needed waypaper matugen swww
