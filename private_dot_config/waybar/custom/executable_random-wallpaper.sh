#!/bin/bash

WALLPAPER="$(find $HOME/.config/walls/ -type f | shuf -n 1)"

swww img "$WALLPAPER" -t any --transition-step 200 --transition-duration 1  --transition-fps 60 &
