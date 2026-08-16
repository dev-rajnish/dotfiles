# =============================================================================
#  Stylix System & User Theming (Driven by 0-var.nix & 2-xdg-config-var.nix)
# =============================================================================
{
  pkgs,
  theme ? "tokyo-night-dark",
  polarity ? "dark",
  xdgVars ? import ../../2-desktop-theme-vars.nix,
  ...
}: let
  inherit (xdgVars) fonts appearance;
in {
  # ---------------------------------------------------------------------------
  # 🎨 Stylix Base Scheme & Targets
  # ---------------------------------------------------------------------------
  stylix = {
    enable = true;
    autoEnable = false;
    enableReleaseChecks = false;
    inherit polarity;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${theme}.yaml";

    targets = {
      gtk.enable = true;
      gtksourceview.enable = true;
      qt.enable = true;
    };

    # -------------------------------------------------------------------------
    # 🖱️ Cursor Theme (Configured in 2-xdg-config-var.nix)
    # -------------------------------------------------------------------------
    cursor = {
      name = appearance.cursor.name;
      size = appearance.cursor.size;
      package = pkgs.bibata-cursors;
    };

    # -------------------------------------------------------------------------
    # 🖼️ Icon Theme (Configured in 2-xdg-config-var.nix)
    # -------------------------------------------------------------------------
    icons = {
      enable = true;
      package = pkgs.tela-circle-icon-theme;
      dark = appearance.iconTheme;
      light = "Tela-circle-light";
    };

    # -------------------------------------------------------------------------
    # 🔤 System & Application Fonts (Configured in 2-xdg-config-var.nix)
    # -------------------------------------------------------------------------
    fonts = {
      sizes.applications = builtins.floor fonts.sizes.desktop;

      emoji = {
        name = fonts.emoji.family;
        package = pkgs.noto-fonts-color-emoji;
      };
      monospace = {
        name = fonts.mono.family;
        package = pkgs.nerd-fonts.jetbrains-mono;
      };
      sansSerif = {
        name = fonts.sans.family;
        package = pkgs.noto-fonts;
      };
      serif = {
        name = fonts.serif.family;
        package = pkgs.noto-fonts;
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
        if polarity == "dark"
        then "prefer-dark"
        else "default";
      cursor-theme = appearance.cursor.name;
      cursor-size = appearance.cursor.size;
      icon-theme =
        if polarity == "dark"
        then appearance.iconTheme
        else "Tela-circle-light";
      font-name = "${fonts.sans.family} ${toString (builtins.floor fonts.sizes.desktop)}";
      document-font-name = "${fonts.sans.family} ${toString (builtins.floor fonts.sizes.desktop)}";
      monospace-font-name = "${fonts.mono.family} ${toString (builtins.floor fonts.sizes.desktop)}";
    };
  };
}
