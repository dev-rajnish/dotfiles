# =============================================================================
#  Standalone Home Manager Configuration Module (modules/home/core.nix)
# =============================================================================
{
  config,
  lib,
  pkgs,
  inputs,
  env,
  ...
}: let
  dotfilesDir = "${config.home.homeDirectory}/${env.dotfilesDir or "shoelace"}";
  ui = env.ui or env;
  fonts = ui.fonts or env.fonts or {};
  sizes = ui.sizes or env.sizes or {};
  cursor = ui.cursor or env.cursor or {};
  icons = ui.icons or env.icons or {};
  theme = env.theme or "rose-pine";
  polarity = env.polarity or "dark";
  desktopFontSize = "${toString (builtins.floor (sizes.desktop or 12.0))}pt";
  getFontName = fontSpec:
    if builtins.isAttrs fontSpec
    then fontSpec.family or fontSpec.name or "Inter"
    else fontSpec;

  schemeName = env.schemeName or "rose-pine";
  schemeFile = "${pkgs.base16-schemes}/share/themes/${schemeName}.yaml";

  # Dynamic dotfile auto-discovery from config/ directory
  configDir = ../../config;
  rawConfigEntries = builtins.readDir configDir;
  validConfigEntries =
    lib.filterAttrs (
      name: _:
        !(lib.hasPrefix "." name)
        && !(lib.hasSuffix "~" name)
        && name != "README.md"
    )
    rawConfigEntries;
  autoConfigFiles =
    lib.mapAttrs' (name: _: {
      name = name;
      value = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/${name}";
      };
    })
    validConfigEntries;
in {
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  # ---------------------------------------------------------------------------
  # 👤 User & Home Manager Identity
  # ---------------------------------------------------------------------------
  home = {
    username = env.username;
    homeDirectory = "/home/${env.username}";
    stateVersion = env.stateVersion;
    enableNixpkgsReleaseCheck = true;

    sessionVariables = {
      EDITOR = env.editor;
      TERMINAL = env.terminal;
      BROWSER = lib.mkDefault env.browser;
      SHELL = "${pkgs.fish}/bin/fish";
      MAN_DISABLE_CACHE = 1;
      SSH_ASKPASS = "";
      GIT_ASKPASS = "";
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    packages = [
      pkgs.shoelace-bin
      pkgs.dconf
      pkgs.antigravity-cli
      pkgs.helium
      pkgs.plain-app
    ];
  };

  # ---------------------------------------------------------------------------
  # 🛠️ Program Configurations
  # ---------------------------------------------------------------------------
  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    man.enable = false;

    zen-browser = {
      enable = true;
      setAsDefaultBrowser = false;
      nativeMessagingHosts = [pkgs.firefoxpwa];
      profiles.default.presets.catppuccin = {
        enable = true;
        flavor = "Mocha";
        accent = "Mauve";
      };
      profiles.default.presets.betterfox.enable = false;
      profiles.default.presets.arkenfox.enable = false;
      profiles.default.settings = {
        "browser.sessionstore.interval" = 1800000;
        "browser.cache.disk.enable" = false;
        "browser.cache.memory.enable" = true;
        "browser.cache.memory.capacity" = 524288;
      };
    };

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-vaapi
        obs-gstreamer
        obs-vkcapture
      ];
    };
  };

  manual.manpages.enable = false;

  # ---------------------------------------------------------------------------
  # 🔗 Dotfile Symlinks
  # ---------------------------------------------------------------------------
  xdg.configFile =
    autoConfigFiles
    // {
      # Custom asset mappings outside config/ directory
      "background".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/assets/wallpaper.jpg";
      "wallpaper.jpg".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/assets/wallpaper.jpg";
    };

  # ---------------------------------------------------------------------------
  # 📁 Imperative MIME Management (Handled via handlr-regex & shoelace templates)
  # ---------------------------------------------------------------------------
  xdg.mimeApps.enable = false;

  # ---------------------------------------------------------------------------
  # 🎨 Stylix Desktop & Base16 Scheme
  # ---------------------------------------------------------------------------
  stylix = {
    enable = true;
    enableReleaseChecks = false;
    autoEnable = false;
    polarity = polarity;
    base16Scheme = schemeFile;

    targets = {
      gtk.enable = true;
      gnome.enable = false;
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = cursor.name or "Bibata-Modern-Classic";
      size = cursor.size or 32;
    };

    icons = {
      enable = true;
      package = pkgs.tela-circle-icon-theme;
      dark = icons.dark or icons.theme or "Tela-circle-dark";
      light = icons.light or icons.theme or "Tela-circle-light";
    };

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

  # ---------------------------------------------------------------------------
  # 🎨 Desktop & Theming Preferences
  # ---------------------------------------------------------------------------
  fonts.fontconfig.enable = true;

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

  news.display = "silent";

  # ---------------------------------------------------------------------------
  # ⚡ Activation Hooks (Dynamic template rendering & live reload)
  # ---------------------------------------------------------------------------
  home.activation = {
    renderShoelaceTemplates = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -d "${dotfilesDir}" ]; then
        $DRY_RUN_CMD echo "👟 Shoelace: Rendering application templates & packages on activation..."
        export PATH="${lib.makeBinPath [pkgs.python3 pkgs.minijinja pkgs.coreutils pkgs.findutils pkgs.gnused pkgs.gawk pkgs.which]}:$PATH"
        if [ -x "${dotfilesDir}/bin/sl-render" ]; then
          $DRY_RUN_CMD "${dotfilesDir}/bin/sl-render" -q || true
        elif [ -f "${dotfilesDir}/bin/sl-render" ]; then
          $DRY_RUN_CMD chmod +x "${dotfilesDir}/bin/sl-render"
          $DRY_RUN_CMD "${dotfilesDir}/bin/sl-render" -q || true
        fi
      fi
    '';

    reloadDesktopSession = lib.hm.dag.entryAfter ["linkGeneration"] ''
      if [ -n "''${WAYLAND_DISPLAY:-}" ] || [ -n "''${DISPLAY:-}" ]; then
        $DRY_RUN_CMD echo "👟 Shoelace: Reloading desktop daemons and styling..."
        ${pkgs.procps}/bin/pkill -SIGUSR1 kitty 2>/dev/null || true
        if ${pkgs.procps}/bin/pgrep -x wbg >/dev/null 2>&1; then
          ${pkgs.procps}/bin/pkill -x wbg 2>/dev/null || true
          ${pkgs.wbg}/bin/wbg -s "${dotfilesDir}/assets/wallpaper.jpg" >/dev/null 2>&1 &
        fi
      fi
    '';
  };
}
