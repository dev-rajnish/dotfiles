#!/usr/bin/env bash
# =============================================================================
#  Clipboard history picker using cliphist and fuzzel
# =============================================================================
cliphist list | fuzzel --dmenu --prompt "📋 Clipboard: " | cliphist decode | wl-copy
