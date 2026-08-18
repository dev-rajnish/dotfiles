# =============================================================================
#  XDG Config Appearance Populator (Typography & Geometry Tokens)
#  Renders layout, font, and geometry parameters from 2-xdg-config-vars.nix
# =============================================================================
{
  config,
  lib,
  pkgs,
  terminal ? "kitty",
  dotfilesDir ? "_ws/dotfiles",
  xdgVars ? import ../../2-xdg-config-vars.nix,
  ...
}: let
  inherit (xdgVars) fonts appearance;
  dotConfigPath = "${config.home.homeDirectory}/.config";

  kittyAppearanceConf = ''
    # Auto-generated from 2-xdg-config-vars.nix - Do not edit manually
    font_family      ${fonts.mono.family}
    italic_font      ${fonts.mono.italicFamily}
    font_features    ${fonts.mono.features}
    font_size        ${toString fonts.sizes.terminal}
  '';

  fuzzelAppearanceIni = ''
    # Auto-generated from 2-xdg-config-vars.nix - Do not edit manually
    [main]
    font=${fonts.mono.family}:size=${toString (builtins.floor fonts.sizes.launcher)}
    terminal=${terminal}

    [border]
    width=${toString appearance.borderWidth}
    radius=${toString appearance.borderRadius}
  '';

  colorsAppearanceCss = ''
    /* Auto-generated from 2-xdg-config-vars.nix - Do not edit manually */

    @define-color font_mono "${fonts.mono.family}";
    @define-color font_sans "${fonts.sans.family}";
    @define-color font_serif "${fonts.serif.family}";

    :root, * {
      --font-mono: "${fonts.mono.family}";
      --font-sans: "${fonts.sans.family}";
      --font-serif: "${fonts.serif.family}";
      --font-size-terminal: ${toString fonts.sizes.terminal}pt;
      --font-size-bar: ${toString fonts.sizes.bar}pt;
      --font-size-launcher: ${toString fonts.sizes.launcher}pt;
      --font-size-desktop: ${toString fonts.sizes.desktop}pt;
      --font-size-power-menu: ${toString fonts.sizes.powerMenu}pt;
      --border-radius: ${toString appearance.borderRadius}px;
      --border-width: ${toString appearance.borderWidth}px;
      --gap-inner: ${toString appearance.gaps.inner}px;
      --gap-outer: ${toString appearance.gaps.outer}px;
    }
  '';

  wlogoutAppearanceCss = ''
    /* Auto-generated from 2-xdg-config-vars.nix - Do not edit manually */
    @define-color font_family "${fonts.sans.family}";
    @define-color font_size ${toString fonts.sizes.powerMenu}pt;
    @define-color border_radius ${toString appearance.borderRadius}px;
    @define-color border_width ${toString appearance.borderWidth}px;

    :root, * {
      --font-family: "${fonts.sans.family}";
      --font-size: ${toString fonts.sizes.powerMenu}pt;
      --border-radius: ${toString appearance.borderRadius}px;
      --border-width: ${toString appearance.borderWidth}px;
    }
  '';

  wayleAppearanceToml = ''
    # Auto-generated from 2-xdg-config-vars.nix - Do not edit manually
    [general]
    font-sans = "${fonts.mono.family}"

    [styling]
    rounding = "${
      if appearance.borderRadius == 0
      then "none"
      else "${toString appearance.borderRadius}px"
    }"
  '';
in {
  # ---------------------------------------------------------------------------
  # 🚀 Populate Layout, Typography & Geometry Files into dot_config/
  # ---------------------------------------------------------------------------
  home.activation.populateXdgVars = lib.hm.dag.entryAfter ["linkGeneration"] ''
        mkdir -p "${dotConfigPath}/kitty" \
                 "${dotConfigPath}/fuzzel" \
                 "${dotConfigPath}/colors" \
                 "${dotConfigPath}/wlogout" \
                 "${dotConfigPath}/wayle"

        cat << 'EOF' > "${dotConfigPath}/kitty/appearance.conf"
    ${kittyAppearanceConf}EOF

        cat << 'EOF' > "${dotConfigPath}/fuzzel/appearance.ini"
    ${fuzzelAppearanceIni}EOF

        cat << 'EOF' > "${dotConfigPath}/colors/appearance.css"
    ${colorsAppearanceCss}EOF

        cat << 'EOF' > "${dotConfigPath}/wlogout/appearance.css"
    ${wlogoutAppearanceCss}EOF

        cat << 'EOF' > "${dotConfigPath}/wayle/appearance.toml"
    ${wayleAppearanceToml}EOF
  '';
}
