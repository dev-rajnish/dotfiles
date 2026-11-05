# =============================================================================
#  Shoelace Flake Core: Unified Token Loader (modules/flake/env.nix)
#  Injects `env` into flake-parts module arguments automatically.
# =============================================================================
{...}: let
  readToken = file: let
    path = ../../allsettings + "/${file}";
  in
    if builtins.pathExists path
    then builtins.fromTOML (builtins.readFile path)
    else {};

  system = readToken "system.toml";
  features = readToken "features.toml";
  apps = readToken "apps.toml";
  theme = readToken "theme.toml";
  ui = readToken "ui.toml";

  themeMap = {
    "catppuccin-latte" = "catppuccin-latte";
    "catppuccin-mocha" = "catppuccin-mocha";
    "cyberpunk" = "tokyo-night-dark";
    "dracula" = "dracula";
    "everforest-dark" = "everforest-dark-medium";
    "gruvbox-dark" = "gruvbox-dark-medium";
    "gruvbox-light" = "gruvbox-light-medium";
    "kanagawa" = "kanagawa";
    "monokai-pro" = "monokai";
    "nord" = "nord";
    "one-dark" = "onedark";
    "rose-pine" = "rose-pine";
    "rose-pine-dawn" = "rose-pine-dawn";
    "tokyo-night" = "tokyo-night-dark";
    "tokyo-night-day" = "tokyo-night-light";
  };

  selectedTheme = theme.theme or "rose-pine";
  schemeName = themeMap.${selectedTheme} or "rose-pine";

  env =
    system
    // features
    // apps
    // theme
    // ui
    // {
      inherit features apps ui themeMap schemeName;
    };
in {
  _module.args.env = env;
}
