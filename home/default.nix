# =============================================================================
#  Standalone Home Manager Configuration Module
# =============================================================================
{
  config,
  lib,
  pkgs,
  inputs,
  env,
  ...
}: let
  dotfilesDir = "${config.home.homeDirectory}/shoelace";
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

  # Antigravity CLI package
  agyVersion = "1.1.13";
  agyUrl = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.13-6057583128215552/linux-x64/cli_linux_x64.tar.gz";
  agyHash = "sha512-icaIG2wZmcuCNucYHCGSro83KwQTOWwPe8/4PSesnAzBICeVzA1insHsv0k30cKUz09eT5+OBbHpcuJxmDE0Qg==";
  antigravityPkg = pkgs.stdenv.mkDerivation {
    pname = "antigravity-cli";
    version = agyVersion;
    src = pkgs.fetchurl {
      url = agyUrl;
      hash = agyHash;
    };
    sourceRoot = ".";
    nativeBuildInputs = [pkgs.autoPatchelfHook];
    buildInputs = [pkgs.stdenv.cc.cc.lib];
    installPhase = ''
      runHook preInstall
      install -m755 -D antigravity $out/bin/agy
      runHook postInstall
    '';
    meta = with lib; {
      description = "Antigravity CLI (agy) - Agentic AI Coding Assistant";
      homepage = "https://antigravity.google";
      mainProgram = "agy";
      platforms = platforms.linux;
    };
  };

  # Helium browser package
  heliumVersion = "0.15.5.1";
  heliumSrc = pkgs.fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${heliumVersion}/helium-${heliumVersion}-x86_64.AppImage";
    hash = "sha256-UC2LpmlRl7V+LRhojqg5VlS7VpMpE99m4/7yiH1KAM4=";
  };
  heliumAppimageContents = pkgs.appimageTools.extractType2 {
    pname = "helium";
    version = heliumVersion;
    src = heliumSrc;
  };
  heliumPkg = pkgs.appimageTools.wrapType2 {
    pname = "helium";
    version = heliumVersion;
    src = heliumSrc;
    extraPkgs = pkgs:
      with pkgs; [
        nss
        nspr
        libdrm
        mesa
        alsa-lib
        vulkan-loader
        libGL
        libglvnd
        wayland
        libxkbcommon
        pciutils
        gtk3
      ];
    extraInstallCommands = ''
      mkdir -p $out/share/applications $out/share/icons/hicolor/512x512/apps
      if [ -f ${heliumAppimageContents}/helium.desktop ]; then
        cp ${heliumAppimageContents}/helium.desktop $out/share/applications/net.imput.helium.desktop
        substituteInPlace $out/share/applications/net.imput.helium.desktop \
          --replace-fail "Exec=helium" "Exec=$out/bin/helium --ozone-platform-hint=auto --enable-features=UseOzonePlatform,OverlayScrollbar --force-dark-mode"
      fi
      if [ -f ${heliumAppimageContents}/helium.png ]; then
        cp ${heliumAppimageContents}/helium.png $out/share/icons/hicolor/512x512/apps/helium.png
      fi
    '';
    meta = with lib; {
      description = "Lightweight, privacy-first Chromium browser by imputnet (AppImage)";
      homepage = "https://github.com/imputnet/helium";
      license = licenses.gpl3Only;
      platforms = ["x86_64-linux"];
      mainProgram = "helium";
    };
  };

  # Relative Shoelace bin scripts package
  shoelaceBin = pkgs.runCommandLocal "shoelace-bin" {} ''
    mkdir -p $out/bin
    cp -a ${../bin}/* $out/bin/
    chmod +x $out/bin/*
  '';

  # PlainApp launcher package
  browserCmd = env.browser or "google-chrome";
  plainAppName = "plainapp";
  plainAppScript = pkgs.writeShellScriptBin plainAppName ''
    gateway_ip=$(ip route show | awk '/default/ {print $3}')

    if [ -z "$gateway_ip" ]; then
      notify-send "PlainApp Error" "Not connected to phone hotspot!"
      exit 1
    fi

    exec ${browserCmd} "https://$gateway_ip:8443"
  '';

  plainAppDesktop = pkgs.makeDesktopItem {
    name = plainAppName;
    desktopName = "PlainApp";
    exec = "${plainAppScript}/bin/${plainAppName}";
    icon = "mobile";
    categories = ["Network" "Utility"];
  };
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
    };

    packages =
      (import ../modules/pkgs/home-manager.nix {inherit pkgs env;}).home-manager.users.${env.username}.home.packages
      ++ [
        shoelaceBin
        pkgs.dconf
        antigravityPkg
        heliumPkg
        plainAppScript
        plainAppDesktop
      ];
  };

  # ---------------------------------------------------------------------------
  # 🛠️ Program Configurations
  # ---------------------------------------------------------------------------
  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    man.enable = false;

    git = {
      enable = true;
      settings = {
        user = {
          name = env.ghUsername;
          email = env.ghEmail;
        };
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = false;
        credential.helper = "libsecret";
        merge.conflictstyle = "diff3";
        diff.algorithm = "histogram";
      };
    };

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
  };

  manual.manpages.enable = false;

  # ---------------------------------------------------------------------------
  # 🔗 Dotfile Symlinks
  # ---------------------------------------------------------------------------
  xdg.configFile = {
    "kitty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/kitty";
    "niri".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/niri";
    "fuzzel".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/fuzzel";
    "handlr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/handlr";
    "mimeapps.list".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/mimeapps.list";
    "wayle".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/wayle";
    "swaylock".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/swaylock";
    "swayidle".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/swayidle";
    "fish".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/fish";
    "yazi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/yazi";
    "fastfetch".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/fastfetch";
    "waypaper".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/waypaper";
    "glow".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/glow";
    "starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/starship.toml";
    "Thunar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/Thunar";
    "autostart-script".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/autostart-script";
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/nvim";
    "background".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/background";
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
}
