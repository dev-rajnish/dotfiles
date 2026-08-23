# =============================================================================
#  Standalone Home Manager Configuration Flake Module
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

  mkHome = {
    system ? "x86_64-linux",
    extraModules ? [],
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = sharedArgs;
      modules =
        [
          self.homeModules.default
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
  flake.homeConfigurations = {
    "${env.username}" = mkHome {};
    "${env.username}@nixos" = mkHome {};
    "${env.username}@amd" = mkHome {};
    "${env.username}@intel" = mkHome {};
  };
}
