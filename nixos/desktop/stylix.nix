# =============================================================================
#  Stylix System-Wide NixOS Module Configuration
# =============================================================================
{
  pkgs,
  lib,
  env,
  ...
}: let
  theme = env.theme or "rose-pine";
  resolveScheme = t: let
    direct = "${pkgs.base16-schemes}/share/themes/${t}.yaml";
    withDark = "${pkgs.base16-schemes}/share/themes/${t}-dark.yaml";
    tokyo = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    fallback = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
  in
    if builtins.pathExists direct
    then direct
    else if builtins.pathExists withDark
    then withDark
    else if t == "tokyo-night"
    then tokyo
    else fallback;
in {
  # ---------------------------------------------------------------------------
  # 🎨 NixOS System-Level Stylix Configuration
  # ---------------------------------------------------------------------------
  stylix = {
    enable = true;
    enableReleaseChecks = false;
    autoEnable = false;
    base16Scheme = resolveScheme theme;
  };
}
