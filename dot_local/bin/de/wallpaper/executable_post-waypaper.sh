#!/bin/bash


matugen -t scheme-vibrant image $1

cp $1 ~/.local/share/wallpapers/current.png

swaybg -i ~/.local/share/wallpapers/current.png & disown

~/.local/bin/wm/post-wallpaper.sh

