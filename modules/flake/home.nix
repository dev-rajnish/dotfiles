# =============================================================================
#  Home Manager Configurations & Modules (modules/flake/home.nix)
#  Exposes `flake.homeModules.default` and `flake.homeConfigurations`
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

  mkHome = {
    system ? "x86_64-linux",
    extraModules ? [],
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [self.overlays.default];
      };
      extraSpecialArgs = sharedArgs;
      modules =
        [
          (inputs.import-tree ../home)
          inputs.stylix.homeModules.stylix
          inputs.nix-index-database.homeModules.default
          {
            programs.nix-index-database.comma.enable = true;
            home = {
              username = env.username;
              homeDirectory = "/home/${env.username}";
              stateVersion = env.stateVersion;
            };
            programs.home-manager.enable = true;
          }
        ]
        ++ extraModules;
    };
in {
  flake.homeModules.default = {
    imports = [
      (inputs.import-tree ../home)
    ];
  };

  flake.homeConfigurations = {
    "${env.username}" = mkHome {};
    "${env.username}@nixos" = mkHome {};
    "${env.username}@amd" = mkHome {};
    "${env.username}@intel" = mkHome {};
  };
}
