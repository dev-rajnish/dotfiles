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
    nh.enable = true;
    niri.enable = true;
    nix-ld.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  # System-wide Core Packages (Hardware, Administration, System Services & Compilers)
  environment.systemPackages = with pkgs; [
    # Core System & Development Utilities
    fish
    alejandra
    curl
    gcc
    git
    home-manager
    starship
    unzip
    wget

    # Containerization & Virtualization Infrastructure
    android-tools
    distrobox
    podman-desktop
    pods

    # Hardware & System Performance Monitoring
    alsa-utils
    pavucontrol
    poptop
    radeontop
    usbtop
    virt-top

    # Wayland & System Management Helpers
    seatd
    xwayland-satellite
  ];
}
