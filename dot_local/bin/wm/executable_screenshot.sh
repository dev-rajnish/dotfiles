#!/bin/bash

#niri msg action screenshot
area=$(slurp)

grim -g "$area" ~/Pictures/$(date +'%Y-%m-%d_%H-%M-%S').png
grim -c -g "$area" - | wl-copy
