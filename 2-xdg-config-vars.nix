# =============================================================================
#  XDG Desktop & Application Styling Variables (Single Source of Truth)
# =============================================================================
{
  # ---------------------------------------------------------------------------
  # 🔤 Typography & Font Sizing
  # ---------------------------------------------------------------------------
  fonts = {
    mono = {
      family = "JetBrainsMono Nerd Font";
      italicFamily = "VictorMono NF Medium Italic";
      features = "VictorMono-Medium +ss01";
    };
    sans = {
      family = "Noto Sans";
      style = "Regular";
    };
    serif = {
      family = "Noto Serif";
      style = "Regular";
    };
    emoji = {
      family = "Noto Color Emoji";
    };

    sizes = {
      terminal = 16.0;
      bar = 12.0;
      launcher = 18.0;
      desktop = 12.0;
      powerMenu = 14.0;
      fastfetchLogo = 18;
    };
  };

  # ---------------------------------------------------------------------------
  # 📐 Geometry, Radii, Gaps & Opacity
  # ---------------------------------------------------------------------------
  appearance = {
    # Sharp (0px) vs Rounded (e.g. 8px, 12px)
    borderRadius = 0;
    borderWidth = 1;
    gaps = {
      inner = 6;
      outer = 6;
      barGap = 2;
    };

    # Window & Bar Opacity
    opacity = {
      terminal = 0.95;
      bar = 0.90;
      overlay = 0.88;
    };

    # Cursors & Icons
    cursor = {
      name = "Bibata-Modern-Ice";
      size = 32;
    };
    iconTheme = "Tela-circle-dark";
  };
}
