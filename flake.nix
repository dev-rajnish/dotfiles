{
  description = "NixOS & Home Manager Configuration Flake";

  inputs = {
    # Note: Flake input URLs require static string literals per Nix Flake specification.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    stylix,
    zen-browser,
    treefmt-nix,
    ...
  }: let
    vars = import ./var.nix;

    sharedArgs =
      vars
      // {
        inherit
          inputs
          self
          nixpkgs
          home-manager
          stylix
          zen-browser
          treefmt-nix
          ;
      };

    pkgs = import nixpkgs {
      inherit (vars) system;
      config.allowUnfree = true;
    };

    treefmtEval = treefmt-nix.lib.evalModule pkgs {
      projectRootFile = "flake.nix";
      programs.alejandra.enable = true;
      programs.fish_indent.enable = true;
      programs.shfmt.enable = true;
      programs.taplo.enable = true;
      programs.prettier.enable = true;
      programs.ruff-format.enable = true;
      programs.stylua.enable = true;
    };
  in {
    checks.${vars.system}.formatting = treefmtEval.config.build.check self;

    nixosConfigurations.${vars.hostname} = nixpkgs.lib.nixosSystem {
      inherit pkgs;
      inherit (vars) system;
      specialArgs = sharedArgs;

      modules = [
        ./nixos/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            backupFileExtension = "backup";
            sharedModules = [stylix.homeModules.stylix];
            users.${vars.username} = import ./home-manager/home.nix;
            extraSpecialArgs = sharedArgs;
          };
        }
      ];
    };

    # Standalone Home Manager configuration
    homeConfigurations.${vars.username} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = sharedArgs;

      modules = [
        ./home-manager/home.nix
        stylix.homeModules.stylix
      ];
    };

    formatter.${vars.system} = treefmtEval.config.build.wrapper;
  };
}
