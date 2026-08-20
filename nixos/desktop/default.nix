# =============================================================================
#  NixOS Desktop Sub-Modules Entrypoint
# =============================================================================
{
  imports = [
    ./display-manager
    ./desktop-environment
    ./key-remapping-kanata.nix
    ./polkit-and-keyring.nix
    ./stylix.nix
    ./system-services.nix
    ./xdg-portals.nix
  ];
}
