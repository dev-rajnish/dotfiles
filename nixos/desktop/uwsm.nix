# =============================================================================
#  Universal Wayland Session Manager (UWSM) Configuration
# =============================================================================
{
  pkgs,
  lib,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🚀 Enable UWSM for Wayland Session Management & Systemd Integration
  # ---------------------------------------------------------------------------
  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      niri = {
        prettyName = "Niri";
        comment = "Niri Wayland Compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/niri";
      };
      hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland Wayland Compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/Hyprland";
      };
    };
  };
}
