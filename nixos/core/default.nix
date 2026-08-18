# =============================================================================
#  NixOS Core Sub-Modules Entrypoint
# =============================================================================
{
  imports = [
    ./dotfiles-sync.nix
    ./networking.nix
    ./nix-settings.nix
    ./shell
    ./time-and-locale.nix
    ./user-accounts.nix
  ];
}
