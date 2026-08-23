# =============================================================================
#  Host Configurations Flake Module (DRY Generator)
# =============================================================================
{
  self,
  inputs,
  ...
}: let
  env = import ../modules/env.toml.nix {};

  sharedArgs =
    env
    // {
      inherit inputs self env;
    };

  mkHost = hostName:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = sharedArgs;
      modules = [
        (../hosts + "/${hostName}")
        self.nixosModules.default
        inputs.stylix.nixosModules.stylix
        inputs.nix-index-database.nixosModules.default

        inputs.home-manager.nixosModules.home-manager
        {
          programs.nix-index-database.comma.enable = true;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = sharedArgs;
            sharedModules = [
              inputs.nix-index-database.homeModules.default
            ];
          };
        }
      ];
    };
in {
  flake.nixosConfigurations = {
    amd = mkHost "amd";
    intel = mkHost "intel";
  };
}
