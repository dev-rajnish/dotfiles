# =============================================================================
#  Declarative Helium Browser Packaging & Configuration (AppImage Version)
#  Ungoogled-Chromium Fork by imputnet with Dark Reader, Bitwarden, Raindrop,
#  Vimium/Tridactyl, DuckDuckGo default, Ask-where-to-save & Compact UI
# =============================================================================
{
  pkgs,
  lib,
  config,
  ...
}: let
  version = "0.15.5.1";

  heliumSrc = pkgs.fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-UC2LpmlRl7V+LRhojqg5VlS7VpMpE99m4/7yiH1KAM4=";
  };

  appimageContents = pkgs.appimageTools.extractType2 {
    pname = "helium";
    inherit version;
    src = heliumSrc;
  };

  heliumPkg = pkgs.appimageTools.wrapType2 {
    pname = "helium";
    inherit version;
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
      if [ -f ${appimageContents}/helium.desktop ]; then
        cp ${appimageContents}/helium.desktop $out/share/applications/net.imput.helium.desktop
        substituteInPlace $out/share/applications/net.imput.helium.desktop \
          --replace-fail "Exec=helium" "Exec=$out/bin/helium --ozone-platform-hint=auto --enable-features=UseOzonePlatform,OverlayScrollbar --force-dark-mode"
      fi
      if [ -f ${appimageContents}/helium.png ]; then
        cp ${appimageContents}/helium.png $out/share/icons/hicolor/512x512/apps/helium.png
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

  # ---------------------------------------------------------------------------
  # 🔒 Enterprise Policy for Helium / Chromium Extensions & Defaults
  # ---------------------------------------------------------------------------
  heliumPolicy = {
    # Extensions auto-installed from Chrome Web Store
    ExtensionInstallForcelist = [
      # 1. Dark Reader (Dark mode for web pages)
      "eimadpbcbfnmbkopoojfekhnkhdbieeh;https://clients2.google.com/service/update2/crx"
      # 2. Bitwarden Password Manager
      "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx"
      # 3. Raindrop.io Bookmark Manager
      "kgbgmghhpaplslbhiajjicmchfkngmbf;https://clients2.google.com/service/update2/crx"
      # 4. Vimium / Tridactyl navigation for Chromium
      "dbepggekoiofhupkpfceeicgebblfioc;https://clients2.google.com/service/update2/crx"
    ];

    # Search Engine: DuckDuckGo Default
    DefaultSearchProviderEnabled = true;
    DefaultSearchProviderName = "DuckDuckGo";
    DefaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
    DefaultSearchProviderNewTabURL = "https://duckduckgo.com";

    # New Tab & Homepage
    HomepageLocation = "https://duckduckgo.com";
    NewTabPageLocation = "https://duckduckgo.com";
    HomepageIsNewTabPage = false;

    # Download Behavior: Ask where to save
    PromptForDownloadLocation = true;
    DownloadDirectory = "${config.home.homeDirectory}/Downloads";
  };
in {
  # Install Helium AppImage package
  home.packages = [
    heliumPkg
  ];

  # ---------------------------------------------------------------------------
  # ⚙️ Enterprise Policies & Default Preferences Config
  # ---------------------------------------------------------------------------
  xdg.configFile = {
    # Enterprise policies for Chromium / Helium engine
    "chromium/policies/managed/helium_policy.json".text = builtins.toJSON heliumPolicy;
    "net.imput.helium/policies/managed/helium_policy.json".text = builtins.toJSON heliumPolicy;

    # Helium User Preferences JSON for DuckDuckGo, Ask-Where-To-Save & Compact UI
    "net.imput.helium/Default/Preferences".text = builtins.toJSON {
      download = {
        default_directory = "${config.home.homeDirectory}/Downloads";
        prompt_for_download = true;
      };
      default_search_provider = {
        enabled = true;
        name = "DuckDuckGo";
        search_url = "https://duckduckgo.com/?q={searchTerms}";
        new_tab_url = "https://duckduckgo.com";
      };
      browser = {
        show_home_button = false;
        compact_ui = true;
      };
    };
  };
}
