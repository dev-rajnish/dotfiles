# =============================================================================
#  Global Configuration Variables (Single Source of Truth)
# =============================================================================
rec {
  # ---------------------------------------------------------------------------
  # ⚙️ Host Platform, CPU & Garbage Collection
  # ---------------------------------------------------------------------------
  system = "x86_64-linux";
  buildCores = 0; # 0 = use all available CPU cores dynamically
  autoGcOlderThan = "7d";

  # ---------------------------------------------------------------------------
  # 👤 User & Host Identification
  # ---------------------------------------------------------------------------
  username = "rsh";
  hostname = "nixos";
  dotfilesDir = "_ws/dotfiles";

  # ---------------------------------------------------------------------------
  # 💻 Hardware & Platform Profile
  # ---------------------------------------------------------------------------
  deviceType = "laptop";
  gpuDriver = "amd";
  enableEarlyKms = false; # Set to true to load GPU driver in initrd (stage 1); false speeds up initrd / sysroot boot
  enableLidInhibit = true; # Set to true to disable laptop lid-switch sleep triggers
  enableKanata = true; # Advanced keyboard remap daemon (Set to true to activate custom layout)

  # ---------------------------------------------------------------------------
  # 🌐 System Localization, Timezone & Keyboard
  # ---------------------------------------------------------------------------
  timeZone = "Asia/Kolkata";
  defaultLocale = "en_US.UTF-8";
  keyboardLayout = "us";
  keyboardPath = ""; # Optional: /dev/input/by-path/... override for kanata

  # ---------------------------------------------------------------------------
  # 🎨 Desktop Theme & Palette (Stylix & Base16)
  # ---------------------------------------------------------------------------
  theme = "catppuccin-mocha";
  polarity = "dark"; # "dark" | "light"

  # ---------------------------------------------------------------------------
  # 🖥️ Default Applications & Workflow (Populated to XDG MIME Handlers)
  # ---------------------------------------------------------------------------
  terminal = "kitty";
  editor = "codium";
  browser = "google-chrome";
  fileManager = "thunar"; # GUI File Manager & Archive Handler
  pdfViewer = "readest"; # PDF & Document Reader
  videoPlayer = "mpv"; # Video Player
  audioPlayer = "vlc"; # Audio Player
  imageViewer = "imv"; # Image Viewer

  # ---------------------------------------------------------------------------
  # ⚡ Feature & Virtualization Toggles
  # ---------------------------------------------------------------------------
  enableAutoLogin = false; # 🔑 TTY1 Automatic login on boot (Set to false for Display Manager / Greetd login)
  enableWaydroid = false;
  enableLibvirt = true;
  enableAppImage = true; # 📦 AppImage runner & binfmt execution support
  enableBluetooth = true;
  enableTailscale = false;
  enableFirewall = false;
  enableProgrammingLang = true; # 🐍 Python, Node, Go, Rust, Zig, Lua & Formatters
  enableDevPkg = true; # 🛠️ Git tools, Linters, Build tools, API clients

  # ---------------------------------------------------------------------------
  # 🐙 Git & GitHub Credentials
  # ---------------------------------------------------------------------------
  ghUsername = "dev-rajnish";
  ghEmail = "dev.rajnish@proton.me";

  # ---------------------------------------------------------------------------
  # 🏷️ NixOS & Home Manager State Version (Unified Single Source of Truth)
  # ---------------------------------------------------------------------------
  stateVersion = "26.05";
  systemVersion = stateVersion;
  homeVersion = stateVersion;
}
