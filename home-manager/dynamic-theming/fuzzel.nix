# =============================================================================
#  Dynamic Theming: Fuzzel Application Launcher
# =============================================================================
{
  pkgs,
  tokens,
}: let
  inherit (tokens) rawColors fonts appearance;

  fuzzelVars = pkgs.writeText "vars.ini" ''
    # Auto-generated from 2-desktop-theme-vars.nix - Do not edit manually
    [main]
    font=${fonts.mono.family}:size=${toString fonts.sizes.launcher}
    terminal=kitty

    [border]
    width=${toString appearance.borderWidth}
    radius=${toString appearance.borderRadius}
  '';

  fuzzelColors = pkgs.writeText "colors.ini" ''
    # Auto-generated from Stylix base16 theme - Do not edit manually
    [colors]
    background=${rawColors.base00}f2
    text=${rawColors.base05}ff
    prompt=${rawColors.base0D}ff
    placeholder=${rawColors.base03}ff
    input=${rawColors.base05}ff
    match=${rawColors.base0E}ff
    selection=${rawColors.base02}ff
    selection-text=${rawColors.base05}ff
    selection-match=${rawColors.base0C}ff
    border=${rawColors.base0D}ff
  '';
in {
  inherit fuzzelVars fuzzelColors;
}
