#!/bin/bash
sudo pacman -S --needed --noconfirm qt6-virtualkeyboard

sudo git clone -b master --depth 1 https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme

sudo cp -r /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/

echo -e "[Theme] \n Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf

sudo mkdir -p /etc/sddm.conf.d

echo -e "[General] \n InputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf
