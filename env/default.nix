# =============================================================================
#  Unified Environment Loader (Nix Single Source of Truth)
let
  # Helper to find and parse TOML file across candidate token directory names
  findToml = name: let
    candidates = [
      (../tokens + "/${name}")
      (../settings + "/${name}")
      (../config + "/${name}")
      (../token.db + "/${name}")
      (../token.kv + "/${name}")
      (../token + "/${name}")
      (../. + "/${name}")
    ];
    existing = builtins.filter builtins.pathExists candidates;
  in
    if existing != []
    then builtins.fromTOML (builtins.readFile (builtins.head existing))
    else {};

  # Read active configuration modules needed by NixOS & Home Manager
  system = findToml "system.toml";
  features = findToml "features.toml";
  apps = findToml "apps.toml";
  theme = findToml "theme.toml";
  ui = findToml "ui.toml";

  # Merged flat & structured environment accessible across NixOS and Home Manager
  env =
    system
    // features
    // apps
    // theme
    // ui
    // {
      inherit
        features
        apps
        ui
        ;
    };

  # Package definitions
  pkgList = import ./packages.nix;
in {
  inherit env pkgList;
}
