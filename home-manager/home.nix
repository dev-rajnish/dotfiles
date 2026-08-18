# =============================================================================
#  Home Manager Main Entrypoint & Static Module Importer
# =============================================================================
{homeVersion, ...}: {
  # Statically import all Home Manager module groups & package integrations
  imports = [
    ./modules
    ./pkgs
  ];

  # Home Manager State Version (Matches 0-system-vars.nix)
  home.stateVersion = homeVersion;
}
