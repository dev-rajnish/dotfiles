{
  config,
  pkgs,
  lib,
  env,
  ...
}: let
  cfg = config.mySystem.theme.stylix-hm;
in {
  options.mySystem.theme.stylix-hm = {
    enable = lib.mkEnableOption "stylix-hm config";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = {
      config,
      pkgs,
      ...
    }: let
      ui = env.ui or env;
      fonts = ui.fonts or env.fonts;
      sizes = ui.sizes or env.sizes;
      cursor = ui.cursor or env.cursor;
      icons = ui.icons or env.icons;
      theme = env.theme or "rose-pine";
      polarity = env.polarity or "dark";

      desktopFontSize = toString (builtins.floor (sizes.desktop or 12.0));
      getFontName = f:
        if builtins.isAttrs f
        then (f.family or f.name or "Inter")
        else f;

      themeMap = {
        "catppuccin-latte" = "catppuccin-latte";
        "catppuccin-mocha" = "catppuccin-mocha";
        "cyberpunk" = "tokyo-night-dark";
        "dracula" = "dracula";
        "everforest-dark" = "everforest-dark-medium";
        "gruvbox-dark" = "gruvbox-dark-medium";
        "gruvbox-light" = "gruvbox-light-medium";
        "kanagawa" = "kanagawa";
        "monokai-pro" = "monokai";
        "nord" = "nord";
        "one-dark" = "onedark";
        "rose-pine" = "rose-pine";
        "rose-pine-dawn" = "rose-pine-dawn";
        "tokyo-night" = "tokyo-night-dark";
        "tokyo-night-day" = "tokyo-night-light";
      };

      schemeName = themeMap.${theme} or "rose-pine";
      schemeFile = "${pkgs.base16-schemes}/share/themes/${schemeName}.yaml";
    in {
      # ---------------------------------------------------------------------------
      # 🎨 Stylix Desktop & Base16 Scheme
      # ---------------------------------------------------------------------------
      stylix = {
        enable = true;
        enableReleaseChecks = false; # Disable mismatched version warning
        autoEnable = false; # Explicitly configure stylix modules rather than globally hijacking configs
        polarity = polarity;
        base16Scheme = schemeFile;

        # Target specific desktop tools for automated styling
        targets = {
          gtk.enable = true;
          gnome.enable = false;
        };

        # -------------------------------------------------------------------------
        # 🖱️ System Cursor (Configured in tokens/ui.toml)
        # -------------------------------------------------------------------------
        cursor = {
          package = pkgs.bibata-cursors;
          name = cursor.name or "Bibata-Modern-Classic";
          size = cursor.size or 32;
        };

        # -------------------------------------------------------------------------
        # 🖼️ Desktop Icon Theme (Configured in tokens/ui.toml)
        # -------------------------------------------------------------------------
        icons = {
          enable = true;
          package = pkgs.tela-circle-icon-theme;
          dark = icons.dark or icons.theme or "Tela-circle-dark";
          light = icons.light or icons.theme or "Tela-circle-light";
        };

        # -------------------------------------------------------------------------
        # 🔤 System & Application Fonts (Configured in tokens/ui.toml)
        # -------------------------------------------------------------------------
        fonts = {
          sizes.applications = builtins.floor (sizes.desktop or 12.0);

          emoji = {
            name = getFontName (fonts.emoji or "Noto Color Emoji");
            package = pkgs.noto-fonts-color-emoji;
          };
          monospace = {
            name = getFontName (fonts.mono or "JetBrainsMono Nerd Font");
            package = pkgs.nerd-fonts.jetbrains-mono;
          };
          sansSerif = {
            name = getFontName (fonts.sans or "Inter");
            package = pkgs.inter;
          };
          serif = {
            name = getFontName (fonts.serif or "Inter");
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
          color-scheme = lib.mkDefault (
            if polarity == "dark"
            then "prefer-dark"
            else "default"
          );
          cursor-theme = lib.mkDefault (cursor.name or "Bibata-Modern-Classic");
          cursor-size = lib.mkDefault (cursor.size or 32);
          icon-theme = lib.mkDefault (
            if polarity == "dark"
            then (icons.dark or icons.theme or "Tela-circle-dark")
            else (icons.light or icons.theme or "Tela-circle-light")
          );
          font-name = lib.mkDefault "${getFontName (fonts.sans or "Inter")} ${desktopFontSize}";
          document-font-name = lib.mkDefault "${getFontName (fonts.sans or "Inter")} ${desktopFontSize}";
          monospace-font-name = lib.mkDefault "${getFontName (fonts.mono or "JetBrainsMono Nerd Font")} ${desktopFontSize}";
        };
      };
    };
  };
}
