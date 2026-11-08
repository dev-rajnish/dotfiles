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
  mkHost = {
    hostFile,
    gpuDriver ? (env.gpuDriver or "amd"),
  }: let
    hostEnv = env // {inherit gpuDriver;};
    hostArgs =
      hostEnv
      // {
        inherit inputs self;
        env = hostEnv;
      };
  in
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = hostArgs;
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
            extraSpecialArgs = hostArgs;
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

  hostConfig = mkHost {
    hostFile = hardwareProfile;
    gpuDriver = env.gpuDriver or "amd";
  };
in {
  flake.nixosConfigurations =
    {
      amd = mkHost {
        hostFile = ../hosts/amd.nix;
        gpuDriver = "amd";
      };
      intel = mkHost {
        hostFile = ../hosts/intel.nix;
        gpuDriver = "intel";
      };
    }
    // (inputs.nixpkgs.lib.genAttrs [env.hostname "nixos"] (_: hostConfig));
}
