# =============================================================================
#  NixOS Hardware Sub-Modules Entrypoint
# =============================================================================
{
  imports = [
    ./bluetooth.nix
    ./bootloader-and-kernel.nix
    ./graphics-amd.nix
    ./power-and-lid.nix
  ];
}
