# =============================================================================
#  Shoelace Environment Token Loader
#  Parses TOML tokens from tokens/ into Nix attributes and exports module args
# =============================================================================
let
  readToken = file: let
    path = ../tokens + "/${file}";
  in
    if builtins.pathExists path
    then builtins.fromTOML (builtins.readFile path)
    else {};

  system = readToken "system.toml";
  features = readToken "features.toml";
  apps = readToken "apps.toml";
  theme = readToken "theme.toml";
  ui = readToken "ui.toml";

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
in
  {lib ? null, ...} @ args:
    if lib != null
    then {
      _module.args.env = env;
    }
    else env
