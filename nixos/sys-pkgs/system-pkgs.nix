{pkgs, ...}: {
  environment.variables = {
    MAN_DISABLE_CACHE = 1;
  };
  programs.nix-ld.package = pkgs.nix-ld;
  environment.systemPackages = with pkgs; [
    home-manager
    nh
    starship
    yazi
    #   nix-ld
    kitty
    jj
    niri
    seatd
    xwayland-satellite
    distrobox
    podman
    podman-desktop
    pods
    zellij
    neovim
    fish
    android-tools
    nerdfetch
    fossil
    eza
    bat
    glow
    git
    curl
    wget
    unzip
    htop
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
    broot # , nnn, ranger (file manager)
    direnv # (load environment variables depending on the current directory)
    httpie # , curlie, xh (for making HTTP requests)
    entr # (run arbitrary commands when files change)
    lazygit # (interactive interfaces for git)
    choose # (the basics of awk/cut)
    atuin # (extremely fancy shell history)
    zoxide
  ];
}
