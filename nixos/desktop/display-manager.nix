# =============================================================================
#  Display Manager & Wayland Console Greeter Service (tuigreet + Greetd)
# =============================================================================
{
  lib,
  pkgs,
  username,
  enableAutoLogin ? false,
  ...
}: let
  # Dynamic session paths on NixOS (System & Home Manager user profiles)
  waylandSessions = "/run/current-system/sw/share/wayland-sessions:/etc/profiles/per-user/${username}/share/wayland-sessions";
  xSessions = "/run/current-system/sw/share/xsessions:/etc/profiles/per-user/${username}/share/xsessions";

  # Formatted tuigreet arguments
  tuigreetArgs = lib.concatStringsSep " " [
    "--time"
    "--time-format '%I:%M %p | %A, %d %B %Y'"
    "--remember"
    "--remember-user-session"
    "--asterisks"
    "--user-menu"
    "--user-menu-min-uid 1000"
    "--user-menu-max-uid 60000"
    "--greeting 'Welcome back to NixOS'"
    "--width 70"
    "--window-padding 2"
    "--container-padding 2"
    "--prompt-padding 1"
    "--sessions ${waylandSessions}"
    "--xsessions ${xSessions}"
    "--cmd labwc"
    "--power-shutdown 'systemctl poweroff'"
    "--power-reboot 'systemctl reboot'"
    "--theme 'border=blue;text=white;prompt=magenta;time=cyan;action=blue;button=yellow;container=black;title=blue;greet=cyan;input=white'"
  ];
in {
  # ---------------------------------------------------------------------------
  # 🔑 Automatic TTY User Login (TTY1) - Enabled only when enableAutoLogin = true
  # ---------------------------------------------------------------------------
  services.getty.autologinUser = lib.mkIf enableAutoLogin username;

  # ---------------------------------------------------------------------------
  # 🖥️ tuigreet Minimalist Terminal Greeter on Greetd
  # ---------------------------------------------------------------------------
  services.greetd = lib.mkIf (!enableAutoLogin) {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.tuigreet} ${tuigreetArgs}";
        user = "greeter";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # 📁 Cache Directory for Persistent Sessions & Last User
  # ---------------------------------------------------------------------------
  systemd.tmpfiles.rules = lib.mkIf (!enableAutoLogin) [
    "d '/var/cache/tuigreet' 0755 greeter greeter - -"
  ];

  # ---------------------------------------------------------------------------
  # 🛡️ Greetd Service Hardening & Clean VT Handover
  # ---------------------------------------------------------------------------
  systemd.services.greetd.serviceConfig = lib.mkIf (!enableAutoLogin) {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Direct stderr to journald to prevent garbled login screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
}
