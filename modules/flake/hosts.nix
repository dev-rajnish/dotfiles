# =============================================================================
#  Host Configurations Flake Module (modules/flake/hosts.nix)
#  Generates `flake.nixosConfigurations` across all machines
# =============================================================================
{
  self,
  inputs,
  env,
  ...
}: let
  sharedArgs =
    env
    // {
      inherit inputs self env;
    };

  mkHost = hostFile:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = sharedArgs;
      modules = [
        hostFile
        (inputs.import-tree ../nixos)
        inputs.stylix.nixosModules.stylix
        inputs.nix-index-database.nixosModules.default

        inputs.home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [self.overlays.default];
          programs.nix-index-database.comma.enable = true;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = sharedArgs;
            sharedModules = [
              inputs.nix-index-database.homeModules.default
            ];
            users.${env.username} = {
              imports = [
                self.homeModules.default
              ];
            };
          };
        }
      ];
    };

  hardwareProfile =
    if builtins.pathExists (../hosts + "/${env.hostname}.nix")
    then (../hosts + "/${env.hostname}.nix")
    else if (env.gpuDriver or "amd") == "intel"
    then ../hosts/intel.nix
    else ../hosts/amd.nix;

  hostConfig = mkHost hardwareProfile;
in {
  flake.nixosConfigurations =
    {
      amd = mkHost ../hosts/amd.nix;
      intel = mkHost ../hosts/intel.nix;
    }
    // (inputs.nixpkgs.lib.genAttrs [env.hostname "nixos"] (_: hostConfig));
}
