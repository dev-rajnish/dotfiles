#!/usr/bin/env bash
# Clipboard history picker using cliphist and fuzzel
cliphist list | fuzzel --dmenu | cliphist decode | wl-copy
