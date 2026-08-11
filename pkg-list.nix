# Package Single Source of Truth
# Accepts pkgs and returns categorized
# package lists for NixOS & Home Manager.
pkgs: {
  # Core System & Hardware Utilities
  systemCore = with pkgs; [
    # Core CLI & Build Tools
    fish
    alejandra
    curl
    gcc
    git
    home-manager
    starship
    unzip
    wget

    # Android & Device Tools
    android-tools

    # Hardware & Performance Monitors
    alsa-utils
    pavucontrol
    poptop
    radeontop
    usbtop

    # Wayland & System Helpers
    seatd
    xwayland-satellite
  ];

  # Virtualization & Container Tools
  virtualization = with pkgs; [
    # QEMU & Libvirt Helpers
    virt-viewer
    virtiofsd # VirtioFS host-guest sharing

    # USB Passthrough Utilities
    usbutils
    usbredir

    # Container Tools
    distrobox
  ];

  # User CLI Utilities & Shell Tools
  cli = with pkgs; [
    # System & Hardware Monitors
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

    # File Search & Text Utilities
    bat
    choose
    eza
    fd
    ripgrep
    sd
    stow
    zoxide

    # Development & Network Tools
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

    # Terminal Visuals & Multiplexers
    cbonsai
    cmatrix
    fortune
    glow
    lolcat
    pipes
    starship
    toilet
    zellij

    # Media & Capture Utilities
    gpu-screen-recorder
    imv
  ];

  # User GUI Applications
  gui = with pkgs; [
    # Web Browsers
    chromium
    firefox-esr
    firefoxpwa
    librewolf-bin
    qutebrowser

    # Desktop Utilities
    kitty
    nwg-displays
    pcmanfm-qt
    process-viewer

    # Media & Document Readers
    calibre
    calibre-web
    mpv
    readest
    vlc
    zathura
  ];

  # Desktop Environment & Wayland Tools
  windowManager = with pkgs; [
    # Launchers & Wallpaper Tools
    fuzzel
    swaybg
    wallust
    waypaper

    # Audio & Brightness Controls
    brightnessctl
    pamixer
    playerctl

    # Lock & Session Management
    swayidle
    swaylock-effects
    wlogout

    # Notifications & Bars
    libnotify
    swaynotificationcenter
    waybar
    wayle

    # Clipboard & Screen Capture
    cliphist
    nwg-clipman
    wl-clipboard
    grim
    slurp
    wev
  ];

  # FHS Environment Packages
  fhs = with pkgs; [
    neovim
    fzf
    yazi
    tree-sitter
    luajit
    rustc
    rustup
    cargo
    rustlings
    rust-analyzer
    zed-editor
  ];
}
