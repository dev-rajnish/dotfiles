# =============================================================================
#  Dynamic Theming: Theme Tokens & Color Resolver
# =============================================================================
{
  config,
  dotfilesDir ? "_ws/dotfiles",
  xdgVars ? import ../../2-desktop-theme-vars.nix,
  ...
}: let
  inherit (xdgVars) fonts appearance;
  dotConfigPath = "${config.home.homeDirectory}/${dotfilesDir}/dot_config";

  # Raw Base16 hex colors (without leading '#')
  rawColors =
    if config ? lib.stylix && config.lib.stylix ? colors
    then config.lib.stylix.colors
    else {
      base00 = "1a1b26";
      base01 = "16161e";
      base02 = "24283b";
      base03 = "565f89";
      base04 = "a9b1d6";
      base05 = "c0caf5";
      base06 = "c0caf5";
      base07 = "c0caf5";
      base08 = "f7768e";
      base09 = "ff9e64";
      base0A = "e0af68";
      base0B = "9ece6a";
      base0C = "7dcfff";
      base0D = "7aa2f7";
      base0E = "bb9af7";
      base0F = "db4b4b";
    };

  # Hex colors with leading '#'
  colors =
    if config ? lib.stylix && config.lib.stylix ? colors
    then let
      c = config.lib.stylix.colors.withHashtag;
    in {
      bg = c.base00;
      bgDark = c.base01;
      bgCard = c.base02;
      bgHighlight = c.base02;
      fg = c.base05;
      fgMuted = c.base04;
      comment = c.base03;
      red = c.base08;
      orange = c.base09;
      yellow = c.base0A;
      green = c.base0B;
      teal = c.base0C;
      cyan = c.base0C;
      blue = c.base0D;
      magenta = c.base0E;
      border = c.base03;
      borderFocus = c.base0D;
    }
    else xdgVars.colors;
in {
  inherit rawColors colors fonts appearance dotConfigPath;
}
