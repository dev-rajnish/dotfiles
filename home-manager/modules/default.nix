# =============================================================================
#  Home Manager Modules Entrypoint
# =============================================================================
{
  imports = [
    ./environment.nix
    ./fhs-environment.nix
    ./git-configuration.nix
    ./mime-defaults.nix
    ./packages.nix
    ./services.nix
    ./shell.nix
    ./stylix.nix
    ./wallust.nix
    ./xdg-config-var-populate.nix
  ];
}
