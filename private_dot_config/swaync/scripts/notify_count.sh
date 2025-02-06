#!/usr/bin/env bash

notif_count="$(swaync-client -c)"

notify-send -e -t 2000 "You have..." "${notif_count} notifications."
