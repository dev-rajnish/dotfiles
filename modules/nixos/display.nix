# =============================================================================
#  Display Managers & Desktop Environments Module (modules/nixos/display.nix)
#  Driven by allsettings/features.toml (displayManager, desktopEnvironment)
# =============================================================================
{
  config,
  lib,
  pkgs,
  env,
  ...
}: let
  dm = env.displayManager or "tuigreet";
  isTuigreet = dm == "tuigreet";
  isLy = dm == "ly";
  isGdm = dm == "gdm";

  de = env.desktopEnvironment or "none";
  enableBudgie = de == "budgie" || (env.enableBudgie or false);
  enableXfce = de == "xfce" || (env.enableXfce or false);

  enableAutoLogin = env.enableAutoLogin or false;
  username = env.username;

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
  # 🖥️ Tuigreet Minimalist Terminal Greeter on Greetd (Default)
  # ---------------------------------------------------------------------------
  services.seatd.enable = isTuigreet;

  services.greetd = lib.mkIf isTuigreet {
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

  systemd.services.greetd.serviceConfig = lib.mkIf isTuigreet {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # ---------------------------------------------------------------------------
  # 🖥️ Ly Console Display Manager
  # ---------------------------------------------------------------------------
  services.displayManager = lib.mkIf (isLy || isGdm) {
    ly = lib.mkIf isLy {
      enable = true;
      settings = {
        bg = 0;
        fg = 7;
        active_fg = 5;
        border_fg = 5;
        bigclock = true;
        blank_box = true;
        hide_borders = false;
        margin_box_h = 2;
        margin_box_v = 1;
        hide_password = false;
        clear_password = false;
        animation = "none";
      };
    };
    gdm = lib.mkIf isGdm {
      enable = true;
      autoSuspend = false;
      settings.debug.enable = false;
    };
    defaultSession = "niri";
  };

  # ---------------------------------------------------------------------------
  # 🌸 Optional Desktop Environments (Budgie / XFCE)
  # ---------------------------------------------------------------------------
  services.desktopManager.budgie = lib.mkIf enableBudgie {
    enable = true;
    extraPlugins = with pkgs; [
      budgie-analogue-clock-applet
    ];
  };

  services.xserver = lib.mkIf enableXfce {
    enable = true;
    desktopManager.xfce.enable = true;
  };
}
