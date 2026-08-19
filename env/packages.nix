# =============================================================================
#  Package Manifest (Single Source of Truth)
#  Categorized Package Manifest for NixOS System & Home Manager
# =============================================================================
args: let
  pkgs = args.pkgs or args;
  enableDevPkg = args.enableDevPkg or true;
  enableProgrammingLang = args.enableProgrammingLang or true;
  lib = pkgs.lib;
in rec {
  # ---------------------------------------------------------------------------
  # ❄️ 01. System-Wide Core Packages (NixOS Level)
  # ---------------------------------------------------------------------------
  systemCore = with pkgs; [
    curl
    wget
    git
    home-manager
    just
    unzip
    seatd
    xwayland-satellite
    starship
    zoxide
    direnv
  ];

  # ---------------------------------------------------------------------------
  # 📦 02. Virtualization, Container & Passthrough Tools
  # ---------------------------------------------------------------------------
  virtualization = with pkgs; [
    appimage-run
    squashfsTools
    distrobox
    usbredir
    usbutils
    virt-viewer
    virtiofsd
  ];

  # ---------------------------------------------------------------------------
  # 💻 03. CLI: Core Editors, Search & Fuzzy Finders
  # ---------------------------------------------------------------------------
  cliCore = with pkgs; [
    neovim
    yazi
    fd
    fzf
    tree-sitter
  ];

  # ---------------------------------------------------------------------------
  # 📊 04. CLI: System Monitoring, Diagnostics & GPU Tools
  # ---------------------------------------------------------------------------
  cliMonitoring = with pkgs; [
    alsa-utils
    btop
    duf
    dust
    fastfetch
    htop
    lm_sensors
    pciutils
    powertop
    radeontop
  ];

  # ---------------------------------------------------------------------------
  # ⚡ 05. CLI: File Manipulation, Text Processing & Automation
  # ---------------------------------------------------------------------------
  cliFileOps = with pkgs; [
    bat
    choose
    eza
    file
    libsecret
    ripgrep
    rsync
    sd
    stow
    tldr
    entr
  ];

  # ---------------------------------------------------------------------------
  # 🗜️ 06. CLI: Archive & Compression
  # ---------------------------------------------------------------------------
  cliArchive = with pkgs; [
    ouch
    p7zip
    unrar
    zip
  ];

  # ---------------------------------------------------------------------------
  # 🐚 07. CLI: Shell Environments
  # ---------------------------------------------------------------------------
  cliShells = with pkgs; [
    fish
  ];

  # ---------------------------------------------------------------------------
  # 🎨 08. CLI: Aesthetics, Multiplexers & Visuals
  # ---------------------------------------------------------------------------
  cliVisuals = with pkgs; [
    cava
    cbonsai
    cmatrix
    glow
    zellij
  ];

  # ---------------------------------------------------------------------------
  # 🎥 09. CLI: Media & Screen Capture
  # ---------------------------------------------------------------------------
  cliMedia = with pkgs; [
    gpu-screen-recorder
    imv
  ];

  # ---------------------------------------------------------------------------
  # 📱 10. CLI: Device & Hardware Tools
  # ---------------------------------------------------------------------------
  cliHardware = with pkgs; [
    android-tools
  ];

  # 🧰 CLI: Aggregate User CLI Package Set
  cli =
    cliCore
    ++ cliMonitoring
    ++ cliFileOps
    ++ cliArchive
    ++ cliShells
    ++ cliVisuals
    ++ cliMedia
    ++ cliHardware;

  # ---------------------------------------------------------------------------
  # 🌐 11. GUI: Web Browsers
  # ---------------------------------------------------------------------------
  guiBrowsers = with pkgs; [
    google-chrome
  ];

  # ---------------------------------------------------------------------------
  # 📝 12. GUI: Code Editors
  # ---------------------------------------------------------------------------
  guiEditors = with pkgs; [
    vscodium-fhs
    antigravity-fhs
    zed-editor-fhs
  ];

  # ---------------------------------------------------------------------------
  # 🎬 13. GUI: Media Players & Audio
  # ---------------------------------------------------------------------------
  guiMedia = with pkgs; [
    mpv
    pwvucontrol
  ];

  # ---------------------------------------------------------------------------
  # 📚 14. GUI: Document Readers
  # ---------------------------------------------------------------------------
  guiDocuments = with pkgs; [
    readest
    zathura
  ];

  # ---------------------------------------------------------------------------
  # 🛠️ 15. GUI: Desktop Utilities & Keyring
  # ---------------------------------------------------------------------------
  guiDesktopUtils = with pkgs; [
    kitty
    nwg-displays
    file-roller
    seahorse
  ];

  # 🖥️ GUI: Aggregate User GUI Package Set
  gui =
    guiBrowsers
    ++ guiEditors
    ++ guiMedia
    ++ guiDocuments
    ++ guiDesktopUtils;

  # ---------------------------------------------------------------------------
  # 🪟 16. Desktop Environment & Wayland Compositor Tools
  # ---------------------------------------------------------------------------
  windowManager = with pkgs; [
    labwc
    wlr-randr
    fuzzel
    mpvpaper
    swaybg
    waypaper
    brightnessctl
    pamixer
    playerctl
    swayidle
    swaylock-effects
    wlogout
    libnotify
    wayle
    cliphist
    grim
    nwg-clipman
    slurp
    wev
    wl-clipboard
  ];

  # ---------------------------------------------------------------------------
  # 🐍 17. Programming Languages, Compilers & Code Formatters
  # ---------------------------------------------------------------------------
  programmingLang = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
    uv
    nodejs_22
    bun
    deno
    go
    rustup
    gcc
    zig
    luajit
    alejandra
    shfmt
    shellcheck
    stylua
    ruff
    prettier
    clang-tools
  ];

  # ---------------------------------------------------------------------------
  # 🛠️ 18. Developer, Git, API & Cloud Tools
  # ---------------------------------------------------------------------------
  devPkg = with pkgs; [
    gh
    delta
    difftastic
    lazygit
    exercism
    rustlings
    httpie
    cloudflared
    wrangler
    cmake
    ninja
    gnumake
    pkg-config
    sqlite
    jq
    jnv
  ];

  # ---------------------------------------------------------------------------
  # 🛠️ 19. FHS Environment (C Headers & External Build Essentials)
  # ---------------------------------------------------------------------------
  fhs = with pkgs; [
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
  # 🔗 20. nix-ld Runtime Shared Libraries (Unpatched Host Binaries)
  # ---------------------------------------------------------------------------
  nixLd = with pkgs; [
    bzip2
    glibc
    stdenv.cc.cc.lib
    xz
    zlib
    zstd
    icu
    libxml2
    systemd
    util-linux
    libkrb5
    libpsl
    openssl
    curl
    nghttp2
    dbus
    glib
    libffi
    libGL
    libglvnd
    libxkbcommon
    mesa
    vulkan-loader
    wayland
    alsa-lib
    libpulseaudio
    fontconfig
    freetype
    expat
    nss
    nspr
    libuv
    fuse3
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
  # 🔤 21. System & Developer Fonts
  # ---------------------------------------------------------------------------
  fonts = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    inter
    noto-fonts-color-emoji
  ];

  # ---------------------------------------------------------------------------
  # 🌟 22. Consolidated Home Manager User Packages
  # ---------------------------------------------------------------------------
  hmPackages =
    cli
    ++ gui
    ++ windowManager
    ++ (lib.optionals enableProgrammingLang programmingLang)
    ++ (lib.optionals enableDevPkg devPkg);
}
