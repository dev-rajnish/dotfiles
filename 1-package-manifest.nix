# =============================================================================
#  Package Single Source of Truth
#  Categorized package lists for NixOS System & Home Manager.
# =============================================================================
args: let
  pkgs =
    if builtins.isAttrs args && args ? pkgs
    then args.pkgs
    else args;
  enableDevPkg =
    if builtins.isAttrs args && args ? enableDevPkg
    then args.enableDevPkg
    else true;
  enableProgrammingLang =
    if builtins.isAttrs args && args ? enableProgrammingLang
    then args.enableProgrammingLang
    else true;
  lib = pkgs.lib;
in rec {
  # ---------------------------------------------------------------------------
  # ❄️ System-Wide Core Packages (NixOS Level)
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
    fish
    starship
    zoxide
    direnv
  ];

  # ---------------------------------------------------------------------------
  # 📦 Virtualization & Container Tools
  # ---------------------------------------------------------------------------
  virtualization = with pkgs; [
    distrobox
    usbredir
    usbutils
    virt-viewer
    virtiofsd
  ];

  # ---------------------------------------------------------------------------
  # 💻 User CLI Utilities & Editors (Home Manager -> hmPackages)
  # ---------------------------------------------------------------------------
  cli = with pkgs; [
    # Core Editors, Fuzzy Finders & File Managers
    neovim
    yazi
    fzf
    tree-sitter

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
    file
    libsecret # Secret Service CLI (secret-tool)
    ripgrep
    sd
    stow
    zoxide
    tldr
    entr

    # Shell Environments
    fish
    nushell

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
  # 🐍 Programming Languages, Compilers & Code Formatters
  # ---------------------------------------------------------------------------
  programmingLang = with pkgs; [
    # Python Runtime & Package Tools
    python3
    python3Packages.pip
    python3Packages.virtualenv
    uv # Fast Python package and project manager

    # JavaScript / TypeScript / Node Runtimes
    nodejs_22
    bun
    deno

    # Systems & Compiled Languages
    go
    rustup
    # rustc
    # cargo
    gcc
    zig

    # Scripting & Lua
    luajit

    # Code Formatters & Linters
    alejandra # Nix Formatter
    shfmt # Shell Script Formatter
    shellcheck # Shell Linter
    stylua # Lua Formatter
    ruff # Fast Python Linter & Formatter
    prettier # Web, Markdown & JSON Formatter
    clang-tools # C/C++ Clang-Format
  ];

  # ---------------------------------------------------------------------------
  # 🛠️ Developer, Git & Toolchain Utilities
  # ---------------------------------------------------------------------------
  devPkg = with pkgs; [
    # Version Control & Collaboration
    gh # GitHub CLI
    delta # Syntax-highlighting pager for git
    difftastic # Semantic structural diff tool
    lazygit # Terminal UI for git
    fossil # Distributed software configuration management
    exercism # Code practice platform CLI
    rustlings

    # API & Cloud / Web Development
    httpie # User-friendly HTTP API client
    cloudflared # Cloudflare Tunnel daemon
    wrangler # Cloudflare Workers CLI

    # Build Systems & Compiling Essentials
    cmake
    ninja
    gnumake
    pkg-config

    # Data, JSON & Database Tools
    sqlite
    jq # Lightweight JSON processor
    jnv # Interactive JSON navigator and jq filter
  ];

  # ---------------------------------------------------------------------------
  # 🖥️ User GUI Applications & Editors (Home Manager -> hmPackages)
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
    seahorse # GNOME Keyring and Password Manager

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
  # 🪟 Desktop Environment & Wayland Tools (Home Manager -> hmPackages)
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
    wayle

    #swaynotificationcenter
    #waybar

    # Clipboard & Screen Capture
    cliphist
    grim
    nwg-clipman
    slurp
    wev
    wl-clipboard
  ];

  # ---------------------------------------------------------------------------
  # 🛠️ FHS Environment (Sandboxed C Headers & External Build Essentials)
  # ---------------------------------------------------------------------------
  fhs = with pkgs; [
    # External Toolchain Managers

    # C Build Essentials & Development Headers for Cargo C-bindings
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
  # 🔗 nix-ld Runtime Shared Libraries (Unpatched Host Binaries)
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

    # Font & Text Rendering (Mason LSPs & GUI tools)
    fontconfig
    freetype
    expat

    # Security, Browser Runtimes & Async IO (Electron / Headless tools)
    nss
    nspr
    libuv

    # AppImage & Filesystem Passthrough
    fuse3

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
  # 🔤 System, Desktop & Developer Nerd Fonts
  # ---------------------------------------------------------------------------
  fonts = with pkgs; [
    # Developer Nerd Fonts
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    nerd-fonts.victor-mono

    # General & Emoji Fonts
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
  ];

  # ---------------------------------------------------------------------------
  # 🌟 Consolidated Home Manager User Packages
  # ---------------------------------------------------------------------------
  hmPackages =
    cli
    ++ gui
    ++ windowManager
    ++ (lib.optionals enableProgrammingLang programmingLang)
    ++ (lib.optionals enableDevPkg devPkg);
}
