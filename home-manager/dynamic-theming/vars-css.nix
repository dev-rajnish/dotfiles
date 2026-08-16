# =============================================================================
#  Dynamic Theming: CSS Variables & Shell Environment Colors
# =============================================================================
{
  pkgs,
  tokens,
}: let
  inherit (tokens) colors fonts appearance;

  # CSS Variables (for wlogout, waybar, GTK)
  varsCss = pkgs.writeText "vars.css" ''
    /* Auto-generated from Stylix base16 theme & 2-desktop-theme-vars.nix - Do not edit manually */
    @define-color bg ${colors.bg};
    @define-color bg_dark ${colors.bgDark};
    @define-color bg_card ${colors.bgCard};
    @define-color bg_highlight ${colors.bgHighlight};
    @define-color bg_translucent rgba(${colors.bg}, 0.85);
    @define-color bg_dark_translucent rgba(${colors.bgDark}, 0.90);
    @define-color fg ${colors.fg};
    @define-color fg_muted ${colors.fgMuted};
    @define-color comment ${colors.comment};
    @define-color blue ${colors.blue};
    @define-color cyan ${colors.cyan};
    @define-color teal ${colors.teal};
    @define-color green ${colors.green};
    @define-color yellow ${colors.yellow};
    @define-color orange ${colors.orange};
    @define-color red ${colors.red};
    @define-color magenta ${colors.magenta};
    @define-color border_color ${colors.border};
    @define-color border_focus ${colors.borderFocus};
    @define-color border_radius ${toString appearance.borderRadius}px;
    @define-color border_width ${toString appearance.borderWidth}px;
    @define-color font_family "${fonts.mono.family}", sans-serif;
    @define-color font_size ${toString fonts.sizes.powerMenu}px;
  '';

  # Shell Environment Theme Variables
  shellColors = pkgs.writeText "colors.sh" ''
    #!/usr/bin/env bash
    # Auto-generated from Stylix base16 theme - Do not edit manually
    export THEME_BG="${colors.bg}"
    export THEME_BG_DARK="${colors.bgDark}"
    export THEME_BG_HIGHLIGHT="${colors.bgHighlight}"
    export THEME_BG_CARD="${colors.bgCard}"
    export THEME_FG="${colors.fg}"
    export THEME_FG_DARK="${colors.fgMuted}"
    export THEME_COMMENT="${colors.comment}"
    export THEME_BLUE="${colors.blue}"
    export THEME_CYAN="${colors.cyan}"
    export THEME_MAGENTA="${colors.magenta}"
    export THEME_ORANGE="${colors.orange}"
    export THEME_YELLOW="${colors.yellow}"
    export THEME_GREEN="${colors.green}"
    export THEME_RED="${colors.red}"
    export THEME_BORDER="${colors.border}"
  '';
in {
  inherit varsCss shellColors;
}
