# =============================================================================
#  NixOS Core Sub-Modules Entrypoint
# =============================================================================
{
  imports = [
    ./networking.nix
    ./nix-settings.nix
    ./shell
    ./time-and-locale.nix
    ./user-accounts.nix
  ];
}
