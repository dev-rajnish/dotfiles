# =============================================================================
#  NixOS Main Entrypoint & Static Module Importer
# =============================================================================
{systemVersion, ...}: {
  # Statically import host hardware configuration & all subsystem module entrypoints
  imports = [
    ./hardware-configuration.nix
    ./core
    ./desktop
    ./hardware
    ./virtualization
  ];

  # NixOS State Version (Matches 0-system-vars.nix)
  system.stateVersion = systemVersion;
}
