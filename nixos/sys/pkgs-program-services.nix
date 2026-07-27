{pkgs, ...}: {
  environment.variables = {
    MAN_DISABLE_CACHE = 1;
  };

  ### Enable the KDE Plasma Desktop Environment.
  #services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  ### DisplayManager
  services.displayManager.sddm.wayland.enable = true;
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "${username}";

  programs = {
    nix-ld.enable = true;
    nh.enable = true;
    niri.enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
    alejandra
    git
    bat
    fish
    yazi
    starship
    kitty
    zellij
    eza
    htop
    #atuin
    zoxide
    wev

    home-manager
    jj
    seatd
    xwayland-satellite
    distrobox
    podman
    podman-desktop
    pods
    android-tools
    nerdfetch
    fossil
    glow
    curl
    wget
    unzip
    jq
    ripgrep
    fd
    gcc
    delta # (a pager for git)
    duf # (df)
    dust # , ncdu (du)
    ncdu
    tldr # (man, sort of)
    sd # (sed)
    difftastic # (diff)
    httpie # , curlie, xh (for making HTTP requests)
    entr # (run arbitrary commands when files change)
    choose # (the basics of awk/cut)
  ];
}
