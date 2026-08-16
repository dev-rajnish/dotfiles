# =============================================================================
#  Display Manager & TTY Auto-Login Service
# =============================================================================
{
  lib,
  pkgs,
  username,
  enableAutoLogin ? false,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🔑 Automatic TTY User Login (TTY1) - Enabled only when enableAutoLogin = true
  # ---------------------------------------------------------------------------
  services.getty.autologinUser = lib.mkIf enableAutoLogin username;

  # ---------------------------------------------------------------------------
  # 🖥️ Greetd with Tuigreet (Robust, Lightweight TUI Greeter)
  # ---------------------------------------------------------------------------
  services.greetd = lib.mkIf (!enableAutoLogin) {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions /run/current-system/sw/share/wayland-sessions:/run/current-system/sw/share/xsessions --cmd niri-session --asterisks --theme border=yellow;text=white;prompt=green;time=yellow;action=blue;button=yellow;container=black;input=white";
        user = "greeter";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # 🛡️ Greetd Service Hardening & Clean VT Handover
  # ---------------------------------------------------------------------------
  # Ensures seamless terminal reset, prevents flickering, and avoids screen spam
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
