{pkgs, ...}: {
  environment.variables = {
    MAN_DISABLE_CACHE = 1;
  };

  # Display Manager Configuration (Ly with Niri default session)
  services.displayManager = {
    defaultSession = "niri";
    ly.enable = true;
  };

  # Program Integrations (System-level services & environment helpers)
  programs = {
    nh.enable = true; # Nix helper CLI tool
    niri.enable = true; # Niri scrollable-tiling Wayland compositor
    nix-ld.enable = true; # Run unpatched dynamic binaries on NixOS

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  # System-wide Core Packages (Hardware, Administration, System Services & Compilers)
  environment.systemPackages = with pkgs; [
    # Core System & Development Utilities
    alejandra # Nix code formatter
    curl # Transfer data with URLs
    gcc # GNU Compiler Collection
    git # Distributed version control system
    home-manager # Home Manager management CLI
    starship # Minimal, blazing-fast, and customizable shell prompt
    unzip # Extraction utility for .zip archives
    wget # Network retriever for downloading files

    # Containerization & Virtualization Infrastructure
    android-tools # Android ADB and Fastboot utilities
    distrobox # Container-based Linux distribution manager
    podman-desktop # Desktop GUI for Podman containers
    pods # Podman pod management GUI

    # Hardware & System Performance Monitoring
    poptop # System performance monitor
    radeontop # AMD GPU monitoring tool
    usbtop # USB bandwidth monitoring utility
    virt-top # Virtualization domain monitor

    # Wayland & System Management Helpers
    seatd # Seat management daemon utility
    xwayland-satellite # XWayland manager for Wayland compositors (Niri)
  ];
}
