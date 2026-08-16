# =============================================================================
#  Dynamic Theming: Swayidle Timeout Configuration
# =============================================================================
{
  pkgs,
  tokens,
}: let
  swayidleConfig = pkgs.writeText "config" ''
    # Auto-generated from Stylix base16 theme - Do not edit manually
    lock 'swaylock -f'
    before-sleep 'swaylock -f'
    timeout 270 'notify-send -u normal -i time "Idle Warning" "Screen will lock in 30 seconds..."'
    timeout 300 'swaylock -f'
    timeout 600 'niri msg action power-off-monitors || hyprctl dispatch dpms off || swaymsg "output * dpms off"'
    resume 'niri msg action power-on-monitors || hyprctl dispatch dpms on || swaymsg "output * dpms on"'
    timeout 1800 'systemctl suspend'
  '';
in {
  inherit swayidleConfig;
}
