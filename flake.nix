# =============================================================================
#  NixOS & Home Manager Unified Flake Configuration
# =============================================================================
{
  description = "Modular NixOS & Home Manager Flake Configuration (Idiomatic Flake-Parts)";

  # ---------------------------------------------------------------------------
  # 1. 📥 Flake Inputs
  # ---------------------------------------------------------------------------
  inputs = {
    # Nixpkgs 26.05 Stable Channel
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Fast binary database for comma / command-not-found
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager 26.05
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix System & User Theming Framework
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen Browser Beta Flake
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Universal Project Formatter
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fast recursive module importer for dendritic architecture
    import-tree.url = "github:vic/import-tree";

    # Flake Parts Framework
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  # ---------------------------------------------------------------------------
  # 2. 📤 Flake Outputs (Dendritic via Flake-Parts Modules)
  # ---------------------------------------------------------------------------
  outputs = inputs @ {
    self,
    flake-parts,
    treefmt-nix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      imports = [
        treefmt-nix.flakeModule
        (inputs.import-tree ./flake-modules)
      ];

      # Per-System Configurations (Formatting, Checks, DevShells)
      perSystem = {
        config,
        pkgs,
        ...
      }: {
        # Treefmt formatting rules
        treefmt.config = {
          projectRootFile = "flake.nix";
          settings.global.excludes = [
            "*.png"
            "*.jpg"
            "*.jpeg"
            "*.scm"
            "*.xml"
            "templates/*"
            "templates/**/*"
          ];
          programs.alejandra.enable = true;
          programs.fish_indent.enable = false;
          programs.shfmt.enable = true;
          programs.taplo.enable = true;
          programs.prettier.enable = true;
          programs.ruff-format.enable = true;
          programs.stylua.enable = true;
        };
      };
    };
}
