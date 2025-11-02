#!/bin/bash

matugen -t scheme-vibrant image $1
swaybg -i $1 & disown
#sleep 1
~/.local/bin/wm/post-wallpaper.sh

