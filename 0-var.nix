# =============================================================================
#  Global Configuration Variables (Single Source of Truth)
# =============================================================================
{
  # ---------------------------------------------------------------------------
  # ⚙️ Host Platform, CPU & Garbage Collection
  # ---------------------------------------------------------------------------
  system = "x86_64-linux";
  buildCores = 12;
  autoGcOlderThan = "7d";

  # ---------------------------------------------------------------------------
  # 👤 User & Host Identification
  # ---------------------------------------------------------------------------
  username = "rsh";
  hostname = "nixos";

  # ---------------------------------------------------------------------------
  # 🌐 System Localization, Timezone & Keyboard
  # ---------------------------------------------------------------------------
  timeZone = "Asia/Kolkata";
  defaultLocale = "en_US.UTF-8";
  keyboardLayout = "us";
  keyboardPath = ""; # Auto-detected dynamically in kanata.nix

  # ---------------------------------------------------------------------------
  # 🖥️ Default Applications & Workflow (Populated to XDG MIME Handlers)
  # ---------------------------------------------------------------------------
  terminal = "kitty";
  editor = "nvim";
  browser = "librewolf";
  fileManager = "pcmanfm-qt"; # GUI File Manager & Archive Handler
  cliFileManager = "yazi"; # CLI Terminal File Manager
  pdfViewer = "org.pwmt.zathura"; # PDF & Document Reader
  videoPlayer = "mpv"; # Video Player
  audioPlayer = "vlc"; # Audio Player
  imageViewer = "imv"; # Image Viewer

  # ---------------------------------------------------------------------------
  # ⚡ Feature & Virtualization Toggles
  # ---------------------------------------------------------------------------
  enableAutoLogin = true; # 🔑 TTY1 Automatic login on boot
  enableWaydroid = true;
  enableLibvirt = true;
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
  # 🏷️ NixOS & Home Manager State Versions
  # ---------------------------------------------------------------------------
  systemVersion = "26.05";
  homeVersion = "26.05";
}
