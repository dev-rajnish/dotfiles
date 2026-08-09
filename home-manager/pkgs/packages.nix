{pkgs, ...}: let
  # CLI Tools & Utilities
  cli = with pkgs; [
    # System & Hardware Monitoring
    batmon
    btop-rocm
    duf
    dust
    ftop
    htop
    lm_sensors
    ncdu
    nerdfetch
    pciutils
    pfetch
    ttop

    # File Management & Search
    bat
    choose
    eza
    fd
    ripgrep
    sd
    stow
    zoxide

    # Development, Networking & Shell Tools
    cloudflared
    delta
    difftastic
    entr
    exercism
    fossil
    fsel
    httpie
    nushell
    tldr
    wrangler

    # Terminal Customization, Visuals & Multiplexing
    cbonsai
    cmatrix
    fortune
    glow
    lolcat
    pipes
    starship
    toilet
    zellij

    # CLI Media & Capture
    gpu-screen-recorder
    imv
  ];

  # GUI Applications
  gui = with pkgs; [
    # Web Browsers & Extensions
    chromium
    firefox-esr
    firefoxpwa
    librewolf-bin
    qutebrowser

    # Desktop Environment & System Utilities
    kitty
    nwg-displays
    pcmanfm-qt
    process-viewer

    # Media Players, E-Books & Document Viewers
    calibre
    calibre-web
    mpv
    readest
    vlc
    zathura
  ];
in {
  home.packages = cli ++ gui;
}
