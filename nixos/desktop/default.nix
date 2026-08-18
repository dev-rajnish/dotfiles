# =============================================================================
#  NixOS Desktop Sub-Modules Entrypoint
# =============================================================================
{
  imports = [
    ./display-manager.nix
    ./key-remapping-kanata.nix
    ./polkit-and-keyring.nix
    ./system-services.nix
    ./xdg-portals.nix
  ];
}
