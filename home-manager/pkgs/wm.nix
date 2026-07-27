{pkgs, ...}: {
  services = {
    # Wallpaper Daemon & OSD
    awww.enable = true;
    swayosd.enable = true;
  };

  programs = {
    atuin.enable = true;
  };

  home.packages = with pkgs; [
    # Wallpaper & Theming
    wallust
    waypaper

    # Brightness & Media Controls
    brightnessctl
    pamixer
    playerctl

    # Screen Lock & Idle Daemon
    swayidle
    swaylock-effects
    wlogout

    # Panel / Status Bar
    waybar
    swaynotificationcenter

    # Clipboard Management
    cliphist
    nwg-clipman
    wl-clipboard

    # Screenshots
    grim
    slurp
  ];
}
