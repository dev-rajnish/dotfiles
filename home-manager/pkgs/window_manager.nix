{pkgs, ...}: let
  # Application Launchers
  launchers = with pkgs; [
    fuzzel
  ];

  # Wallpaper & Color Scheme Generators
  appearance = with pkgs; [
    swaybg
    wallust
    waypaper
  ];

  # Audio, Media & Brightness Controls
  controls = with pkgs; [
    brightnessctl
    pamixer
    playerctl
  ];

  # Screen Lock, Idle & Session Management
  session = with pkgs; [
    swayidle
    swaylock-effects
    wlogout
  ];

  # Status Bar & Notification Services
  barsAndNotifications = with pkgs; [
    libnotify
    swaynotificationcenter
    waybar
    wayle
  ];

  # Clipboard History & Managers
  clipboard = with pkgs; [
    cliphist
    nwg-clipman
    wl-clipboard
  ];

  # Screen Capture & Event Utilities
  screenCapture = with pkgs; [
    grim
    slurp
    wev
  ];

  wmPackages =
    launchers
    ++ appearance
    ++ controls
    ++ session
    ++ barsAndNotifications
    ++ clipboard
    ++ screenCapture;
in {
  # Services for Desktop Session
  services = {
    wayle.autoInstallDependencies = true;
  };

  # Shell History & Navigation Programs
  programs = {
    atuin.enable = true;
    eza = {
      enable = true;
      enableFishIntegration = true;
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  # Wayland Environment & Helper Packages
  home.packages = wmPackages;
}
