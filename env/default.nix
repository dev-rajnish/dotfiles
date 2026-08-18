# =============================================================================
#  Unified Environment Loader
# =============================================================================
let
  # List of all modular TOML configuration files to import
  tomlFiles = [
    ./system.toml
    ./apps.toml
    ./features.toml
    ./theme.toml
    ./appearance.toml
    ./shell.toml
  ];

  # Load and merge all TOML files into a single flat environment attribute set
  env =
    builtins.foldl' (
      acc: file: acc // (builtins.fromTOML (builtins.readFile file))
    ) {}
    tomlFiles;

  # Package definitions
  pkgList = import ./packages.nix;
in {
  inherit env pkgList;
}
