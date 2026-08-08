{pkgs, ...}: {
  # Services for Desktop Session
  services = {
    wayle.autoInstallDependencies = true;
  };

  # Integrated Shell / History Programs
  programs = {
    atuin.enable = true;
    eza.enable = true;
    eza.enableFishIntegration = true;
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  # Wayland Compositor (Niri), Window Manager Helpers & Environment Packages
  home.packages = with pkgs; [
    # Application Launchers
    fuzzel

    # Wallpaper & Color Palette Generators
    swaybg
    wallust
    waypaper

    # Audio, Media & Screen Brightness Controls
    brightnessctl
    pamixer
    playerctl

    # Screen Lock, Idle & Session Management
    swayidle
    swaylock-effects
    wlogout

    # Status Bar & Notifications
    swaynotificationcenter
    libnotify
    waybar
    wayle

    # Clipboard History & Managers
    cliphist
    nwg-clipman
    wl-clipboard

    # Screenshot & Display Event Utilities
    grim
    slurp
    wev
  ];
}
