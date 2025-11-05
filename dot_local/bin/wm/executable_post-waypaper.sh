#!/bin/bash

current_wallpaper='~/.local/share/wallpapers/current.png'

matugen -t scheme-vibrant image $1

cp $1 $current_wallpaper

swaybg -i $current_wallpaper & disown
#sleep 1
~/.local/bin/wm/post-wallpaper.sh

