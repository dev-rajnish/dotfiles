# =============================================================================
#  NixOS & Home Manager Modules Exporter (Dendritic Module Auto-Discovery)
# =============================================================================
{inputs, ...}: {
  flake.nixosModules.default = inputs.import-tree ../modules;
  flake.homeModules.default = import ../home;
}
