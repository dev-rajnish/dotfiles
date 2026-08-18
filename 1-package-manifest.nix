# =============================================================================
#  Package Single Source of Truth
#  Categorized & Structured Package Manifest for NixOS System & Home Manager
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
    curl # Command-line tool for transferring data with URLs
    wget # Network utility to retrieve files from the web
    git # Distributed version control system
    home-manager # User environment and dotfiles manager
    just # Handy command runner and modern makefile alternative
    unzip # Extraction utility for .zip compressed archives
    seatd # Minimal seat management daemon for Wayland compositors
    xwayland-satellite # Standalone XWayland manager for rootless X11 apps on Wayland
    starship # Fast, cross-shell customizable prompt
    zoxide # Smarter cd command that learns frequently accessed paths
    direnv # Shell extension to load/unload environment variables per directory (.envrc)
  ];

  # ---------------------------------------------------------------------------
  # 📦 02. Virtualization, Container & Hardware Passthrough Tools
  # ---------------------------------------------------------------------------
  virtualization = with pkgs; [
    appimage-run # CLI launcher for unpatched binary AppImages on NixOS
    squashfsTools # Extract and inspect AppImage squashfs filesystem contents
    distrobox # Container-based dev environments on host using podman/docker
    usbredir # Protocol for redirecting USB devices over network to VM guests
    usbutils # Linux USB device inspection utilities (lsusb)
    virt-viewer # Lightweight graphical viewer for SPICE & VNC virtual machine consoles
    virtiofsd # High-performance host-guest shared filesystem daemon for QEMU/KVM
  ];

  # ---------------------------------------------------------------------------
  # 💻 03. CLI: Core Editors, Search & Fuzzy Finders
  # ---------------------------------------------------------------------------
  cliCore = with pkgs; [
    neovim # Highly extensible terminal text editor
    yazi # Blazing fast async terminal file manager written in Rust
    fd # Simple, fast and user-friendly alternative to find
    fzf # General-purpose command-line fuzzy finder
    tree-sitter # Incremental parsing framework for syntax highlighting
  ];

  # ---------------------------------------------------------------------------
  # 📊 04. CLI: System Monitoring, Hardware Diagnostics & GPU Tools
  # ---------------------------------------------------------------------------
  cliMonitoring = with pkgs; [
    alsa-utils # ALSA soundcard configuration and CLI mixer tools (alsamixer, aplay)
    btop # Lightweight, fast resource monitor with process and hardware tracking
    duf # Disk Usage/Free utility with clean, formatted terminal tables
    dust # Intuitive graphical disk space analyzer (du + rust)
    fastfetch # Fast, feature-rich neofetch alternative written in C
    htop # Interactive process viewer and resource monitor
    lm_sensors # Hardware health monitoring tools (CPU temps, fan speeds, voltages)
    pciutils # PCI bus inspection utilities (lspci)
    powertop # Linux utility to diagnose and optimize laptop battery power consumption
    radeontop # Real-time AMD Radeon GPU utilization monitor (VRAM, compute units, clocks)
  ];

  # ---------------------------------------------------------------------------
  # ⚡ 05. CLI: Modern File Manipulation, Text Processing & Automation
  # ---------------------------------------------------------------------------
  cliFileOps = with pkgs; [
    bat # Cat clone with syntax highlighting and Git integration
    choose # Fast, human-friendly alternative to cut and awk fields (0-indexed slicing)
    eza # Modern, feature-rich replacement for ls with git status and icons
    file # Utility to determine file type from magic numbers
    libsecret # Secret Service API client providing secret-tool for keyring credential access
    ripgrep # Blazingly fast recursive regex search tool (rg)
    sd # Intuitive search & replace CLI alternative to sed with standard regex
    stow # GNU symlink farm manager for dotfiles
    tldr # Simplified, community-driven practical man page summaries
    entr # Event-driven file watcher that runs commands when files change
  ];

  # ---------------------------------------------------------------------------
  # 🗜️ 06. CLI: Archive, Compression & Extraction Tools
  # ---------------------------------------------------------------------------
  cliArchive = with pkgs; [
    ouch # Painless compression & decompression CLI (infers format from file extension)
    p7zip # 7-Zip high-compression archive utility
    unrar # Extraction utility for proprietary RAR archives
    zip # Standard ZIP archive creation utility
  ];

  # ---------------------------------------------------------------------------
  # 🐚 07. CLI: Shell Environments & Interactive Shells
  # ---------------------------------------------------------------------------
  cliShells = with pkgs; [
    nushell # Modern shell powered by structured data pipelines and typed tables
  ];

  # ---------------------------------------------------------------------------
  # 🎨 08. CLI: Terminal Aesthetics, Fun, Multiplexers & Visuals
  # ---------------------------------------------------------------------------
  cliVisuals = with pkgs; [
    cava # Console-based Audio Visualizer for ALSA, PulseAudio and PipeWire
    cbonsai # Procedural bonsai tree generator in terminal using ASCII/Unicode
    cmatrix # Matrix digital rain terminal screen saver
    glow # Terminal markdown reader with custom styling and pager support
    zellij # Modern terminal multiplexer with tabs, panes, and floating layouts
  ];

  # ---------------------------------------------------------------------------
  # 🎥 09. CLI: Media, Graphics & Hardware Screen Capture
  # ---------------------------------------------------------------------------
  cliMedia = with pkgs; [
    gpu-screen-recorder # Ultra high-performance screen recorder using hardware NVENC/VA-API
    imv # Fast, lightweight Wayland/X11 image viewer with tiling WM keybindings
  ];

  # ---------------------------------------------------------------------------
  # 📱 10. CLI: Device, Hardware & Protocol Tools
  # ---------------------------------------------------------------------------
  cliHardware = with pkgs; [
    android-tools # ADB (Android Debug Bridge) and Fastboot tools
  ];

  # ---------------------------------------------------------------------------
  # 🧰 CLI: Aggregate User CLI Package Set (Home Manager -> hmPackages)
  # ---------------------------------------------------------------------------
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
  # 🌐 11. GUI: Web Browsers & Internet Tools
  # ---------------------------------------------------------------------------
  guiBrowsers = with pkgs; [
    google-chrome # Google Chrome web browser
  ];

  # ---------------------------------------------------------------------------
  # 📝 12. GUI: Code Editors & Development Environments
  # ---------------------------------------------------------------------------
  guiEditors = with pkgs; [
    vscodium-fhs # Binary distribution of VS Code without Microsoft telemetry
    antigravity-fhs
    zed-editor-fhs # High-performance, multiplayer code editor written in Rust
  ];

  # ---------------------------------------------------------------------------
  # 🎬 13. GUI: Media Players & Audio Controls
  # ---------------------------------------------------------------------------
  guiMedia = with pkgs; [
    mpv # Highly customizable, high-performance media player
    pwvucontrol # Modern PipeWire Volume Control GUI (GTK4 pavucontrol alternative)
  ];

  # ---------------------------------------------------------------------------
  # 📚 14. GUI: Document Readers, E-Books & Library Management
  # ---------------------------------------------------------------------------
  guiDocuments = with pkgs; [
    readest # Modern document, PDF, and e-book reader GUI
    zathura # Minimalist, keyboard-driven document and PDF viewer with vim-like bindings
  ];

  # ---------------------------------------------------------------------------
  # 🛠️ 15. GUI: Desktop Utilities, Display Tools & Keyring Managers
  # ---------------------------------------------------------------------------
  guiDesktopUtils = with pkgs; [
    kitty # GPU-accelerated terminal emulator with Wayland protocols and tabs
    nwg-displays # Wayland GUI output and display layout management utility for wlroots
    file-roller # GNOME archive manager GUI (backend for Thunar archive plugin)
    seahorse # GNOME password, secret key, and GPG keyring manager GUI
  ];

  # ---------------------------------------------------------------------------
  # 🖥️ GUI: Aggregate User GUI Package Set (Home Manager -> hmPackages)
  # ---------------------------------------------------------------------------
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
    wlr-randr # Wayland wlroots output and display scaling CLI utility
    # Launchers & Wallpaper Tools
    fuzzel # Lightweight Wayland application launcher (dmenu/rofi alternative)
    mpvpaper # Video wallpaper utility for Wayland compositors using mpv
    swaybg # Minimal wallpaper setter for Wayland wlroots compositors
    wallust # Dynamic colorscheme and palette generator from wallpapers (v3)
    waypaper # GUI frontend for wallpaper managers (swaybg, mpvpaper)

    # Hardware & Audio Controls
    brightnessctl # Device backlight and LED brightness controller CLI
    pamixer # Pulseaudio / PipeWire command-line audio mixer
    playerctl # MPRIS media player controller CLI for hardware media keys

    # Lock, Idle & Session Management
    swayidle # Idle management daemon for Wayland
    swaylock-effects # Screen locker for Wayland with blur, fade-in, and ring effects
    wlogout # Wayland-native power menu and session logout dialog

    # Notifications & Status Bars
    libnotify # Desktop notifications library providing notify-send
    wayle # Modern, highly customizable status bar and widget shell for Wayland

    # Clipboard & Screen Capture
    cliphist # Wayland clipboard history manager with binary/image caching
    grim # Wayland screenshot utility
    nwg-clipman # GTK3 GUI clipboard history manager for Wayland
    slurp # Wayland interactive screen region selector (pairs with grim)
    wev # Wayland event viewer for debugging keycodes and pointer events
    wl-clipboard # Command-line copy and paste utilities (wl-copy, wl-paste) for Wayland
  ];

  # ---------------------------------------------------------------------------
  # 🐍 17. Programming Languages, Compilers & Code Formatters
  # ---------------------------------------------------------------------------
  programmingLang = with pkgs; [
    # Python Runtime & Package Tools
    python3 # Python 3 interpreter
    python3Packages.pip # Python package installer
    python3Packages.virtualenv # Virtual Python environment builder
    uv # Fast Python package and project manager written in Rust

    # JavaScript / TypeScript / Node Runtimes
    nodejs_22 # Node.js JavaScript runtime (v22 LTS)
    bun # Fast all-in-one JavaScript/TypeScript runtime and bundler
    deno # Secure TypeScript and JavaScript runtime

    # Systems & Compiled Languages
    go # The Go programming language toolchain
    rustup # Rust toolchain installer and version manager
    gcc # GNU Compiler Collection (C/C++)
    zig # General-purpose programming language and toolchain for robust software

    # Scripting & Lua
    luajit # High-performance Just-In-Time compiler for Lua

    # Code Formatters & Linters
    alejandra # Uncompromising Nix code formatter
    shfmt # Shell script formatter
    shellcheck # Static analysis tool for shell scripts
    stylua # Opinionated Lua code formatter
    ruff # Extremely fast Python linter and formatter written in Rust
    prettier # Multi-language code formatter (JS/TS, CSS, Markdown, JSON)
    clang-tools # Standalone command-line C/C++ tools including clang-format
  ];

  # ---------------------------------------------------------------------------
  # 🛠️ 18. Developer, Git, API & Cloud Toolchain Utilities
  # ---------------------------------------------------------------------------
  devPkg = with pkgs; [
    # Version Control & Collaboration
    gh # Official GitHub CLI
    delta # Syntax-highlighting pager for git diffs
    difftastic # Structural diff tool that compares code syntax trees
    lazygit # Terminal UI for git commands and interactive rebasing
    exercism # Command-line client for code practice on Exercism.org
    rustlings # Small guided exercises to get used to reading and writing Rust code

    # API & Cloud / Web Development
    httpie # User-friendly HTTP API client with syntax highlighting and JSON formatting
    cloudflared # Cloudflare Tunnel daemon for zero-trust port exposure
    wrangler # Official Cloudflare Workers & Pages developer CLI

    # Build Systems & Compiling Essentials
    cmake # Cross-platform open-source build system generator
    ninja # Small build system with a focus on speed
    gnumake # GNU Make build automation tool
    pkg-config # Package compiler and linker flag configuration helper

    # Data, JSON & Database Tools
    sqlite # Self-contained, serverless SQL database engine
    jq # Lightweight and flexible command-line JSON processor
    jnv # Interactive JSON navigator and live jq expression previewer
  ];

  # ---------------------------------------------------------------------------
  # 🛠️ 19. FHS Environment (Sandboxed C Headers & External Build Essentials)
  # ---------------------------------------------------------------------------
  fhs = with pkgs; [
    cmake # CMake build system generator
    gcc # GNU C/C++ compiler
    glibc.dev # C standard library development headers
    gnumake # GNU make utility
    libxml2.dev # XML parsing library development files
    openssl.dev # Cryptography and SSL/TLS development headers
    pkg-config # Compiler/linker flag querying tool
    zlib.dev # Compression library development headers
  ];

  # ---------------------------------------------------------------------------
  # 🔗 20. nix-ld Runtime Shared Libraries (Unpatched Host Binaries)
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
  # 🔤 21. System, Desktop & Developer Nerd Fonts
  # ---------------------------------------------------------------------------
  fonts = with pkgs; [
    # Developer Nerd Fonts (Minimal tailored subset for Tokyo Night & terminal)
    nerd-fonts.jetbrains-mono # Primary monospace font for terminal, editor & UI
    nerd-fonts.symbols-only # Pure icon font for powerline, octicons & devicons

    # General & Emoji Fonts
    noto-fonts # Google Noto standard font family for global language support
    noto-fonts-color-emoji # Google Noto Color Emoji font
    font-awesome # Iconic font and CSS framework for UI glyphs
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
