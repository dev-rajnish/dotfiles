#!/bin/bash

# ╭──────────────────────────────────────────────────────────╮
# │ Define options with corresponding icons                  │
# ╰──────────────────────────────────────────────────────────╯
options="    Lock Screen\n    Logout\n    Shutdown\n    Restart"

selected_option=$(echo -e "$options" | fuzzel -l 5 -w 14 --dmenu --prompt "Select an action : ")

# ╭──────────────────────────────────────────────────────────╮
# │ Function to display the confirmation prompt              │
# ╰──────────────────────────────────────────────────────────╯
confirmation_prompt() {
  action=$1
  confirmation=$(echo -e "Yes\nNo" | fuzzel --dmenu -l 3 -w 12 --prompt "Confirm  to $action ? ")

  if [ "$confirmation" == "Yes" ]; then
    echo "Proceeding with $action..."
    return 0
  else
    echo "Action canceled."
    return 1
  fi
}

# ╭──────────────────────────────────────────────────────────╮
# │ Execute the selected option                              │
# ╰──────────────────────────────────────────────────────────╯
case "$selected_option" in
"    Lock Screen")
  hyprlock -c ~/.config/hypr/hyprlock.conf
  ;;
"    Logout")
  # Ask for confirmation before logging out
  if confirmation_prompt "logout"; then
    hyprctl dispatch exit
  fi
  ;;
"    Shutdown")
  # Ask for confirmation before shutting down
  if confirmation_prompt "shutdown"; then
    systemctl poweroff
  fi
  ;;
"    Restart")
  # Ask for confirmation before restarting
  if confirmation_prompt "restart"; then
    systemctl reboot
  fi
  ;;
*)
  echo "Invalid option selected."
  ;;
esac
