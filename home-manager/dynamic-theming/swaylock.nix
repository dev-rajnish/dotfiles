# =============================================================================
#  Dynamic Theming: Swaylock-Effects Configuration
# =============================================================================
{
  pkgs,
  tokens,
}: let
  inherit (tokens) rawColors fonts;

  swaylockConfig = pkgs.writeText "config" ''
    # Auto-generated Swaylock-Effects Configuration - Do not edit manually

    # Visual Effects & Display
    screenshots
    clock
    indicator
    indicator-radius=120
    indicator-thickness=10
    indicator-idle-visible
    effect-blur=7x5
    effect-vignette=0.5:0.5
    fade-in=0.2
    grace=2
    grace-no-mouse
    grace-no-touch
    font="${fonts.sans.family}"

    # Base Background Color
    color=${rawColors.base00}

    # Ring Colors
    ring-color=${rawColors.base0D}
    ring-clear-color=${rawColors.base0B}
    ring-caps-lock-color=${rawColors.base0A}
    ring-ver-color=${rawColors.base0D}
    ring-wrong-color=${rawColors.base08}

    # Inside Circle Fill Colors (Translucent)
    inside-color=${rawColors.base00}b3
    inside-clear-color=${rawColors.base00}b3
    inside-caps-lock-color=${rawColors.base00}b3
    inside-ver-color=${rawColors.base00}b3
    inside-wrong-color=${rawColors.base00}b3

    # Key Typing Highlights & Backspace
    key-hl-color=${rawColors.base0E}
    bs-hl-color=${rawColors.base08}

    # Line Borders (Transparent for modern flat look)
    line-color=${rawColors.base00}00
    line-clear-color=${rawColors.base00}00
    line-caps-lock-color=${rawColors.base00}00
    line-ver-color=${rawColors.base00}00
    line-wrong-color=${rawColors.base00}00
    separator-color=${rawColors.base00}00

    # Typography & Status Text Colors
    text-color=${rawColors.base05}
    text-clear-color=${rawColors.base05}
    text-caps-lock-color=${rawColors.base0A}
    text-ver-color=${rawColors.base05}
    text-wrong-color=${rawColors.base08}
  '';
in {
  inherit swaylockConfig;
}
