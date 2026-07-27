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
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    stylix,
    ...
  }: let
    vars = import ./var.nix;

    sharedArgs =
      vars
      // {
        inherit
          self
          nixpkgs
          home-manager
          stylix
          ;
      };

    pkgs = import nixpkgs {
      inherit (vars) system;
      config.allowUnfree = true;
    };
  in {
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

    formatter.${vars.system} = pkgs.alejandra;
  };
}
