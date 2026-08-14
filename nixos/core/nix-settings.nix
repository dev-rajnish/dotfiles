# =============================================================================
#  Nix Daemon Settings, Binary Caches & Garbage Collection
# =============================================================================
{system, ...}: {
  # Host Platform
  nixpkgs.hostPlatform = system;

  # ---------------------------------------------------------------------------
  # 1. ⚙️ Nix Settings & Performance Flags
  # ---------------------------------------------------------------------------
  nix.settings = {
    # Enable modern Nix Command and Flakes features
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Automatically hardlink identical store files
    auto-optimise-store = true;

    # Build Concurrency
    max-jobs = "auto";
    cores = 12;

    # Binary Cache Substituters
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];

    # Trusted Public Keys for Binary Caches
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    always-allow-substitutes = true;
    use-xdg-base-directories = true;
  };

  # ---------------------------------------------------------------------------
  # 2. 🧹 Automatic Store Garbage Collection
  # ---------------------------------------------------------------------------
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Disable documentation manual page cache generation to speed up builds
  documentation.man.cache.enable = false;
}
