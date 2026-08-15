# Package Single Source of Truth
# Categorized package lists for NixOS System & Home Manager.
pkgs: rec {
  # ---------------------------------------------------------------------------
  # 1. ❄️ System-Wide Core Packages (NixOS Level)
  # ---------------------------------------------------------------------------
  systemCore = with pkgs; [
    curl
    git
    home-manager
    just
    unzip
    wget
    seatd
    xwayland-satellite
  ];

  # ---------------------------------------------------------------------------
  # 2. 📦 Virtualization & Container Tools
  # ---------------------------------------------------------------------------
  virtualization = with pkgs; [
    distrobox
    usbredir
    usbutils
    virt-viewer
    virtiofsd
  ];

  # ---------------------------------------------------------------------------
  # 3. 💻 User CLI Utilities & Editors (Home Manager -> hmPackages)
  # ---------------------------------------------------------------------------
  cli = with pkgs; [
    # Core Editors, Fuzzy Finders & File Managers
    neovim
    yazi
    fzf
    tree-sitter
    luajit

    # System, Hardware & GPU Monitors
    alsa-utils
    batmon
    btop-rocm
    duf
    dust
    fastfetch
    ftop
    htop
    lm_sensors
    ncdu
    nerdfetch
    onefetch
    pciutils
    pfetch
    poptop
    powertop
    radeontop
    ttop
    usbtop

    # Device & Hardware Tools
    android-tools

    # File, Search & Text Utilities
    bat
    choose
    eza
    fd
    ripgrep
    sd
    stow
    zoxide

    # Development, Shell & Network Tools
    alejandra
    cloudflared
    delta
    difftastic
    entr
    exercism
    fish
    fossil
    fsel
    gcc
    gh
    httpie
    nushell
    python3
    tldr
    wrangler

    # Terminal Visuals & Multiplexers
    cava
    cbonsai
    cmatrix
    fortune
    glow
    lolcat
    pipes
    starship
    toilet
    zellij

    # CLI Media Tools
    gpu-screen-recorder
    imv
  ];

  # ---------------------------------------------------------------------------
  # 4. 🖥️ User GUI Applications & Editors (Home Manager -> hmPackages)
  # ---------------------------------------------------------------------------
  gui = with pkgs; [
    # GUI Code Editors
    zed-editor

    # Web Browsers
    chromium
    firefox-esr
    qutebrowser

    # Desktop Utilities & Volume Controls
    kitty
    nwg-displays
    pcmanfm-qt
    process-viewer
    pwvucontrol

    # Qt Platform Themes (qt5ct & qt6ct)
    # libsForQt5.qt5ct
    # qt6Packages.qt6ct

    # Media & Document Readers
    calibre
    calibre-web
    mpv
    readest
    vlc
    zathura
  ];

  # ---------------------------------------------------------------------------
  # 5. 🪟 Desktop Environment & Wayland Tools (Home Manager -> hmPackages)
  # ---------------------------------------------------------------------------
  windowManager = with pkgs; [
    # Launchers & Wallpaper Tools
    fuzzel
    mpvpaper
    swaybg
    wallust
    waypaper

    # Hardware & Audio Controls
    brightnessctl
    pamixer
    playerctl

    # Lock, Idle & Session Management
    swayidle
    swaylock-effects
    wlogout

    # Notifications & Status Bars
    libnotify
    swaynotificationcenter
    waybar
    wayle

    # Clipboard & Screen Capture
    cliphist
    grim
    nwg-clipman
    slurp
    wev
    wl-clipboard
  ];

  # ---------------------------------------------------------------------------
  # 6. 🛠️ FHS Environment (Sandboxed Rust Toolchains & C Build Essentials)
  # ---------------------------------------------------------------------------
  fhs = with pkgs; [
    # Rust Toolchain & SDKs
    cargo
    rust-analyzer
    rustc
    rustlings
    rustup

    # Standard Build Tools & C Headers for Cargo C-bindings
    cmake
    gcc
    glibc.dev
    gnumake
    libxml2.dev
    openssl.dev
    pkg-config
    zlib.dev
  ];

  # ---------------------------------------------------------------------------
  # 7. 🔗 nix-ld Runtime Shared Libraries (Unpatched Host Binaries)
  # ---------------------------------------------------------------------------
  nixLd = with pkgs; [
    # C/C++ & Core Runtimes
    bzip2
    glibc
    stdenv.cc.cc.lib
    xz
    zlib
    zstd

    # System & Utilities
    icu
    libxml2
    systemd
    util-linux

    # Security & Crypto
    libkrb5
    libpsl
    openssl

    # Network & Transfer
    curl
    nghttp2

    # GLib & Desktop Foundations
    dbus
    glib
    libffi

    # Graphics, Rendering & Wayland
    libGL
    libglvnd
    libxkbcommon
    mesa
    vulkan-loader
    wayland

    # Audio
    alsa-lib
    libpulseaudio

    # X11 Top-Level Libraries
    libX11
    libXcursor
    libXext
    libXfixes
    libXi
    libXinerama
    libXrandr
    libXrender
    libXtst
    libxcb
  ];

  # ---------------------------------------------------------------------------
  # 8. 🌟 Consolidated Home Manager User Packages
  # ---------------------------------------------------------------------------
  hmPackages = cli ++ gui ++ windowManager;
}
