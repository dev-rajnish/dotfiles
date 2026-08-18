# =============================================================================
#  NixOS Main Entrypoint & Static Module Importer
# =============================================================================
{stateVersion, ...}: {
  # Statically import host hardware configuration & all subsystem module entrypoints
  imports = [
    ./hardware-configuration.nix
    ./core
    ./desktop
    ./hardware
    ./virtualization
  ];

  # NixOS State Version (Matches system.toml stateVersion)
  system.stateVersion = stateVersion;
}
