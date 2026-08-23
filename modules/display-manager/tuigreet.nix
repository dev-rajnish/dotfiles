{
  config,
  lib,
  pkgs,
  env,
  ...
}: let
  cfg = config.mySystem.display-manager.tuigreet;
in {
  options.mySystem.display-manager.tuigreet = {
    enable = lib.mkEnableOption "tuigreet config";
  };

  config = lib.mkIf cfg.enable (
    let
      enableAutoLogin = env.enableAutoLogin or false;
      username = env.username;

      # Formatted tuigreet arguments using lib.cli.toCommandLineShellGNU
      tuigreetArgs = lib.cli.toCommandLineShellGNU {} {
        sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions:${config.services.displayManager.sessionData.desktops}/share/xsessions";
        cmd = "${pkgs.niri}/bin/niri-session";
        time = true;
        time-format = "%I:%M %p | %A, %d %B %Y";
        user-menu = true;
        user-menu-min-uid = 1000;
        user-menu-max-uid = 60000;
        remember = true;
        remember-session = true;
        asterisks = true;
        greeting = "Welcome back to NixOS";
        width = 70;
        window-padding = 2;
        container-padding = 2;
        prompt-padding = 1;
        power-shutdown = "systemctl poweroff";
        power-reboot = "systemctl reboot";
      };
    in {
      # ---------------------------------------------------------------------------
      # 💺 Seat Management Service
      # ---------------------------------------------------------------------------
      services.seatd.enable = true;

      # ---------------------------------------------------------------------------
      # 🖥️ tuigreet Minimalist Terminal Greeter on Greetd & Autologin Support
      # ---------------------------------------------------------------------------
      services.greetd = {
        enable = true;
        settings = {
          initial_session = lib.mkIf enableAutoLogin {
            command = "${pkgs.niri}/bin/niri-session";
            user = username;
          };

          default_session = {
            command = "${lib.getExe pkgs.tuigreet} ${tuigreetArgs}";
            user = "greeter";
          };
        };
      };

      # ---------------------------------------------------------------------------
      # 🛡️ Greetd Service Hardening & Clean VT Handover
      # ---------------------------------------------------------------------------
      systemd.services.greetd.serviceConfig = {
        Type = "idle";
        StandardInput = "tty";
        StandardOutput = "tty";
        StandardError = "journal"; # Direct stderr to journald to prevent garbled login screen
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
      };
    }
  );
}
