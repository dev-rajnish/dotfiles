# =============================================================================
#  Dynamic Theming: Wayle Status Bar Theme Palettes
# =============================================================================
{
  pkgs,
  tokens,
}: let
  inherit (tokens) colors;

  waylePalette = pkgs.writeText "dynamic.toml" ''
    # Auto-generated from Stylix base16 theme - Do not edit manually
    [palette]
    bg = "${colors.bgDark}"
    surface = "${colors.bg}"
    elevated = "${colors.bgCard}"
    fg = "${colors.fg}"
    fg-muted = "${colors.fgMuted}"
    primary = "${colors.blue}"
    red = "${colors.red}"
    yellow = "${colors.yellow}"
    green = "${colors.green}"
    blue = "${colors.cyan}"
  '';

  waylePaletteJson = pkgs.writeText "dynamic.json" ''
    {
      "bg": "${colors.bgDark}",
      "surface": "${colors.bg}",
      "elevated": "${colors.bgCard}",
      "fg": "${colors.fg}",
      "fg_muted": "${colors.fgMuted}",
      "primary": "${colors.blue}",
      "red": "${colors.red}",
      "yellow": "${colors.yellow}",
      "green": "${colors.green}",
      "blue": "${colors.cyan}"
    }
  '';
in {
  inherit waylePalette waylePaletteJson;
}
