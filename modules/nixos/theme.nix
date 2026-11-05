# =============================================================================
#  Stylix System-Level Theming Framework (modules/nixos/theme.nix)
# =============================================================================
{
  config,
  pkgs,
  lib,
  env,
  ...
}: let
  polarity = env.polarity or "dark";
  schemeName = env.schemeName or "rose-pine";
  schemeFile = "${pkgs.base16-schemes}/share/themes/${schemeName}.yaml";
in {
  stylix = {
    enable = true;
    enableReleaseChecks = false;
    autoEnable = false;
    polarity = polarity;
    base16Scheme = schemeFile;
  };
}
