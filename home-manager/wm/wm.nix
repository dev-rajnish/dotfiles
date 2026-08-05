{pkgs, ...}: {
  # Services for Desktop Session
  services = {
    # awww.enable = true; # Wallpaper daemon service for Wayland
    # swayosd.enable = true; # On-Screen Display overlay for volume & brightness
    # wayle.enable = true;
    wayle.autoInstallDependencies = true;
  };

  # Integrated Shell / History Programs
  programs = {
    atuin.enable = true; # Shell history sync and search tool
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
    fuzzel # Wayland application launcher and dmenu replacement

    # Wallpaper & Color Palette Generators
    swaybg # wallpaper engine
    wallust # Pywal-like palette generator from wallpaper images
    waypaper # Graphical wallpaper picker for Wayland wallpaper daemons

    # Audio, Media & Screen Brightness Controls
    brightnessctl # Device brightness controller for backlight & LEDs
    pamixer # Pulseaudio / PipeWire command-line volume control
    playerctl # Command-line utility and library for MPRIS media players

    # Screen Lock, Idle & Session Management
    swayidle # Idle management daemon for Wayland compositors
    swaylock-effects # Screen locker for Wayland with blur & background effects
    wlogout # Graphical logout menu for Wayland compositors

    # Status Bar & Notifications
    swaynotificationcenter # GTK notification center daemon and widget
    waybar # Highly customizable Wayland desktop status bar
    wayle

    # Clipboard History & Managers
    cliphist # Wayland clipboard manager with support for text and images
    nwg-clipman # GTK3 clipboard manager GUI for cliphist
    wl-clipboard # Command-line copy and paste utilities for Wayland

    # Screenshot & Display Event Utilities
    grim # Screen capture utility for Wayland
    slurp # Select a region in a Wayland compositor and print it to stdout
    wev # Wayland event viewer (useful for testing keybinds and mouse events)
  ];
}
