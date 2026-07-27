{pkgs, ...}: {
  environment.variables = {
    MAN_DISABLE_CACHE = 1;
  };

  # Display Manager Configuration
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Program Integrations
  programs = {
    nh.enable = true;
    niri.enable = true;
    nix-ld.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    # Core CLI Tools & Utilities
    alejandra
    android-tools
    bat
    btop-rocm
    choose
    curl
    delta
    difftastic
    distrobox
    duf
    dust
    entr
    eza
    fd
    fish
    fossil
    ftop
    fuzzel
    gcc
    git
    glow
    home-manager
    htop
    httpie
    jq
    kitty
    ncdu
    nerdfetch
    podman
    podman-desktop
    pods
    poptop
    radeontop
    ripgrep
    sd
    seatd
    starship
    tldr
    ttop
    ungoogled-chromium
    unzip
    usbtop
    virt-top
    wev
    wget
    xwayland-satellite
    yazi
    zellij
    zoxide
  ];
}
