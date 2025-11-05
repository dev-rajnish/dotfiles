#!/bin/bash
theme=$(gsettings get org.gnome.desktop.interface gtk-theme)
echo $theme
gsettings set org.gnome.desktop.interface gtk-theme Nordic-master
gsettings set org.gnome.desktop.interface gtk-theme $theme
gsettings set org.gnome.desktop.wm.preferences theme adw-gtk3-dark

sudo flatpak override --filesystem=xdg-config/gtk-3.0
sudo flatpak override --filesystem=xdg-config/gtk-4.0
