# =============================================================================
#  Dynamic Theming: Kitty Terminal Palette & Fonts
# =============================================================================
{
  pkgs,
  tokens,
}: let
  inherit (tokens) rawColors fonts appearance;

  kittyColors = pkgs.writeText "colors.conf" ''
    # Auto-generated Base16 Kitty Palette - Do not edit manually
    background #${rawColors.base00}
    foreground #${rawColors.base05}
    selection_background #${rawColors.base02}
    selection_foreground #${rawColors.base05}
    url_color #${rawColors.base0C}
    cursor #${rawColors.base05}
    cursor_text_color #${rawColors.base00}

    # Tabs
    active_tab_background #${rawColors.base0D}
    active_tab_foreground #${rawColors.base00}
    inactive_tab_background #${rawColors.base01}
    inactive_tab_foreground #${rawColors.base04}
    tab_bar_background #${rawColors.base00}

    # Windows
    active_border_color #${rawColors.base0D}
    inactive_border_color #${rawColors.base01}

    # Normal ANSI Colors (0-7)
    color0 #${rawColors.base00}
    color1 #${rawColors.base08}
    color2 #${rawColors.base0B}
    color3 #${rawColors.base0A}
    color4 #${rawColors.base0D}
    color5 #${rawColors.base0E}
    color6 #${rawColors.base0C}
    color7 #${rawColors.base05}

    # Bright ANSI Colors (8-15)
    color8  #${rawColors.base03}
    color9  #${rawColors.base08}
    color10 #${rawColors.base0B}
    color11 #${rawColors.base0A}
    color12 #${rawColors.base0D}
    color13 #${rawColors.base0E}
    color14 #${rawColors.base0C}
    color15 #${rawColors.base07}

    # Extended (16-17)
    color16 #${rawColors.base09}
    color17 #${rawColors.base0F}

    # Background & Transparency (Configured dynamically in 2-desktop-theme-vars.nix)
    background_opacity ${toString appearance.opacity.terminal}
    dynamic_background_opacity yes
  '';

  kittyFonts = pkgs.writeText "fonts.conf" ''
    # Auto-generated from 2-desktop-theme-vars.nix - Do not edit manually
    font_family      ${fonts.mono.family}
    italic_font      ${fonts.mono.italicFamily}
    font_features    ${fonts.mono.features}
    font_size        ${toString fonts.sizes.terminal}
  '';
in {
  inherit kittyColors kittyFonts;
}
