# =============================================================================
#  NixOS & Home Manager Unified Flake Configuration
# =============================================================================
{
  description = "Modular NixOS & Home Manager Flake Configuration";

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

    # nix gui software store
    nix-software-center.url = "github:snowfallorg/nix-software-center";
  };

  # ---------------------------------------------------------------------------
  # 2. 📤 Flake Outputs
  # ---------------------------------------------------------------------------
  outputs = inputs @ {
    self,
    nixpkgs,
    nix-index-database,
    home-manager,
    stylix,
    zen-browser,
    treefmt-nix,
    nix-software-center,
    ...
  }: let
    # Load unified environment configuration and package manifest
    inherit (import ./env) env pkgList;

    # Arguments passed to all sub-modules
    sharedArgs =
      env
      // {
        inherit
          inputs
          self
          nixpkgs
          nix-index-database
          home-manager
          stylix
          zen-browser
          treefmt-nix
          pkgList
          env
          ;
      };

    # Import nixpkgs with unfree software support
    pkgs = import nixpkgs {
      inherit (env) system;
      config.allowUnfree = true;
    };

    # Treefmt formatting rules
    treefmtEval = treefmt-nix.lib.evalModule pkgs {
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
      programs.fish_indent.enable = true;
      programs.shfmt.enable = true;
      programs.taplo.enable = true;
      programs.prettier.enable = true;
      programs.ruff-format.enable = true;
      programs.stylua.enable = true;
    };
  in {
    # Flake check: verify code formatting
    checks.${env.system}.formatting = treefmtEval.config.build.check self;

    # -------------------------------------------------------------------------
    # ❄️ NixOS System Configuration
    # -------------------------------------------------------------------------
    nixosConfigurations.${env.hostname} = nixpkgs.lib.nixosSystem {
      inherit pkgs;
      inherit (env) system;
      specialArgs = sharedArgs;

      modules = [
        ./nixos/configuration.nix
        nix-index-database.nixosModules.default
        stylix.nixosModules.stylix
        # Optional: wrap and install comma command-not-found helper
        {programs.nix-index-database.comma.enable = true;}

        # Integrated Home Manager Module
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            sharedModules = [
              nix-index-database.homeModules.default
            ];
            users.${env.username} = import ./home-manager/home.nix;
            extraSpecialArgs = sharedArgs;
          };
        }
      ];
    };

    # -------------------------------------------------------------------------
    # 🏠 Standalone Home Manager Configuration
    # -------------------------------------------------------------------------
    homeConfigurations.${env.username} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = sharedArgs;

      modules = [
        ./home-manager/home.nix
        stylix.homeModules.stylix
        nix-index-database.homeModules.default
      ];
    };

    # Treefmt CLI wrapper (`nix fmt`)
    formatter.${env.system} = treefmtEval.config.build.wrapper;
  };
}
