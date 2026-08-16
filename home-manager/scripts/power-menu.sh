#!/usr/bin/env bash
# =============================================================================
#  Power & Session Menu using Fuzzel
# =============================================================================

# Options with icons
LOCK="󰌾  Lock"
LOGOUT="󰍃  Logout"
SLEEP="󰤄  Sleep"
REBOOT="󰜉  Reboot"
SHUTDOWN="󰐥  Shutdown"

# Helper to execute sleep.sh
run_sleep() {
  for script_path in \
    "$(dirname "$(realpath "$0")")/sleep.sh" \
    "$HOME/_ws/dotfiles/home-manager/scripts/sleep.sh" \
    "$HOME/dotfiles/home-manager/scripts/sleep.sh" \
    "$HOME/_ws/dotfiles/scripts/sleep.sh" \
    "$HOME/dotfiles/scripts/sleep.sh" \
    "$HOME/.dotfiles/scripts/sleep.sh"; do
    if [ -x "$script_path" ]; then
      exec "$script_path"
    fi
  done
  # Fallback if script not found directly
  if command -v sleep.sh >/dev/null 2>&1; then
    exec sleep.sh
  else
    pamixer --mute 2>/dev/null
    exec systemctl suspend
  fi
}

# Present menu via Fuzzel dmenu mode
CHOICE=$(printf "%s\n%s\n%s\n%s\n%s" "$LOCK" "$LOGOUT" "$SLEEP" "$REBOOT" "$SHUTDOWN" |
  fuzzel --dmenu \
    --prompt "Power: " \
    --placeholder "Select session action..." \
    --lines 5 \
    --width 18 \
    --horizontal-pad 20 \
    --vertical-pad 15)

case "$CHOICE" in
"$LOCK")
  swaylock -f || swaylock
  ;;
"$LOGOUT")
  niri msg action quit --skip-confirmation 2>/dev/null || pkill niri || loginctl terminate-session self
  ;;
"$SLEEP")
  run_sleep
  ;;
"$REBOOT")
  systemctl reboot
  ;;
"$SHUTDOWN")
  systemctl poweroff
  ;;
*)
  exit 0
  ;;
esac
