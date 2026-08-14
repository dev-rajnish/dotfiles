# =============================================================================
#  Stylix System & User Theming (Tokyo Night Dark Scheme)
# =============================================================================
{pkgs, ...}: {
  # ---------------------------------------------------------------------------
  # 1. 🎨 Stylix Base Scheme & Targets
  # ---------------------------------------------------------------------------
  stylix = {
    enable = true;
    autoEnable = false;
    enableReleaseChecks = false;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

    targets = {
      gtk.enable = true;
      gtksourceview.enable = true;
      qt.enable = true;
    };

    # -------------------------------------------------------------------------
    # 🖱️ Cursor Theme
    # -------------------------------------------------------------------------
    cursor = {
      name = "Bibata-Modern-Ice";
      size = 32;
      package = pkgs.bibata-cursors;
    };

    # -------------------------------------------------------------------------
    # 🖼️ Icon Theme
    # -------------------------------------------------------------------------
    icons = {
      enable = true;
      package = pkgs.tela-circle-icon-theme;
      dark = "Tela-circle";
      light = "Tela-circle-light";
    };

    # -------------------------------------------------------------------------
    # 🔤 System & Application Fonts
    # -------------------------------------------------------------------------
    fonts = {
      sizes.applications = 16;

      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };
      monospace = {
        name = "Noto Sans Mono";
        package = pkgs.noto-fonts;
      };
      sansSerif = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };
      serif = {
        name = "Noto Serif";
        package = pkgs.noto-fonts;
      };
    };
  };

  # ---------------------------------------------------------------------------
  # 2. 🌙 Global Dark Mode Preference for XDG Portals, GNOME, GTK & Flatpaks
  # ---------------------------------------------------------------------------
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
