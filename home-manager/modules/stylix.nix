# =============================================================================
#  Stylix System & User Theming (GTK3/4, Qt6ct, Cursor, Icons & Fonts)
# =============================================================================
{
  pkgs,
  env,
  ...
}: let
  desktopFontSize = toString (builtins.floor (env.fonts.sizes.desktop or 12.0));
in {
  # ---------------------------------------------------------------------------
  # 🎨 Stylix Base Scheme & Targets
  # ---------------------------------------------------------------------------
  stylix = {
    enable = true;
    autoEnable = false;
    enableReleaseChecks = false;
    inherit (env) polarity;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${env.theme}.yaml";

    targets = {
      gtk.enable = true;
      gtksourceview.enable = true;
      qt.enable = true;
    };

    # -------------------------------------------------------------------------
    # 🖱️ Cursor Theme (Configured in env/appearance.toml)
    # -------------------------------------------------------------------------
    cursor = {
      name = env.appearance.cursor.name;
      size = env.appearance.cursor.size;
      package = pkgs.bibata-cursors;
    };

    # -------------------------------------------------------------------------
    # 🖼️ Icon Theme (Configured in env/appearance.toml)
    # -------------------------------------------------------------------------
    icons = {
      enable = true;
      package = pkgs.tela-circle-icon-theme;
      dark = env.appearance.iconTheme;
      light = "Tela-circle-light";
    };

    # -------------------------------------------------------------------------
    # 🔤 System & Application Fonts (Configured in env/appearance.toml)
    # -------------------------------------------------------------------------
    fonts = {
      sizes.applications = builtins.floor env.fonts.sizes.desktop;

      emoji = {
        name = env.fonts.emoji.family;
        package = pkgs.noto-fonts-color-emoji;
      };
      monospace = {
        name = env.fonts.mono.family;
        package = pkgs.nerd-fonts.jetbrains-mono;
      };
      sansSerif = {
        name = env.fonts.sans.family;
        package = pkgs.inter;
      };
      serif = {
        name = env.fonts.serif.family;
        package = pkgs.inter;
      };
    };
  };

  # Ensure user fontconfig cache is enabled and regenerated
  fonts.fontconfig.enable = true;

  # ---------------------------------------------------------------------------
  # 🌙 Global Desktop & Interface Preferences (XDG Portals, GNOME, GTK & Flatpaks)
  # ---------------------------------------------------------------------------
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme =
        if env.polarity == "dark"
        then "prefer-dark"
        else "default";
      cursor-theme = env.appearance.cursor.name;
      cursor-size = env.appearance.cursor.size;
      icon-theme =
        if env.polarity == "dark"
        then env.appearance.iconTheme
        else "Tela-circle-light";
      font-name = "${env.fonts.sans.family} ${desktopFontSize}";
      document-font-name = "${env.fonts.sans.family} ${desktopFontSize}";
      monospace-font-name = "${env.fonts.mono.family} ${desktopFontSize}";
    };
  };
}
