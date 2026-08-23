{
  config,
  lib,
  env,
  ...
}: let
  cfg = config.mySystem.system.nix-settings;
in {
  options.mySystem.system.nix-settings = {
    enable = lib.mkEnableOption "nix-settings config";
  };

  config = lib.mkIf cfg.enable {
    # Host Platform
    nixpkgs.hostPlatform = env.system;

    # ---------------------------------------------------------------------------
    # ⚙️ Nix Settings & Performance Flags
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
      cores = env.buildCores;

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
    # 🧹 Automatic Store Garbage Collection
    # ---------------------------------------------------------------------------
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than ${env.autoGcOlderThan}";
    };

    # ---------------------------------------------------------------------------
    # 📚 Documentation Minimization (Speed up builds & trim store size)
    # ---------------------------------------------------------------------------
    documentation = {
      enable = false;
      man.enable = false;
      man.cache.enable = false;
      nixos.enable = false; # Disable heavy NixOS HTML manual derivation
      doc.enable = false; # Disable extra documentation
      info.enable = false; # Disable GNU info pages
    };
  };
}
