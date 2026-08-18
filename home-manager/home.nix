# =============================================================================
#  Home Manager Main Entrypoint & Static Module Importer
# =============================================================================
{stateVersion, ...}: {
  # Statically import all Home Manager module groups & package integrations
  imports = [
    ./modules
    ./pkgs
  ];

  # Home Manager State Version (Matches system.toml stateVersion)
  home.stateVersion = stateVersion;
}
