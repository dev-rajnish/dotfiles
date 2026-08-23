{
  env,
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.mySystem.apps.qutebrowser;
in {
  options.mySystem.apps.qutebrowser = {
    enable = lib.mkEnableOption "qutebrowser config";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = {
      config,
      pkgs,
      ...
    }: {
      # ---------------------------------------------------------------------------
      # 📦 Package Dependencies (Bitwarden CLI & Aria2 External Downloader)
      # ---------------------------------------------------------------------------
      home.packages = with pkgs; [
        aria2
        bitwarden-cli
      ];

      # ---------------------------------------------------------------------------
      # 🐍 Qutebrowser Declarative Configuration
      # ---------------------------------------------------------------------------
      programs.qutebrowser = {
        enable = true;

        # 🔍 Search Engine Setup (DuckDuckGo Default)
        searchEngines = {
          "DEFAULT" = "https://duckduckgo.com/?q={}";
          "ddg" = "https://duckduckgo.com/?q={}";
          "g" = "https://www.google.com/search?q={}";
          "nw" = "https://wiki.nixos.org/w/index.php?search={}";
          "yt" = "https://www.youtube.com/results?search_query={}";
        };

        # 🌐 Qutebrowser Fine-tuned Settings
        settings = {
          # New Tab & Default Start Page
          url.start_pages = ["https://duckduckgo.com"];
          url.default_page = "https://duckduckgo.com";

          # 📥 Downloads: Ask where to save & location prompt
          downloads.location.prompt = true;
          downloads.location.directory = "${config.home.homeDirectory}/Downloads";
          downloads.position = "top";
          downloads.remove_finished = 5000;

          # 🌙 Dark Reader Equivalent (Native Smart Dark Mode Engine)
          colors.webpage.preferred_color_scheme = "dark";
          colors.webpage.darkmode.enabled = true;
          colors.webpage.darkmode.algorithm = "smart-rgb";
          colors.webpage.darkmode.policy.images = "never";

          # 🛡️ Privacy, Adblock & Greasemonkey Script Support
          content.blocking.enabled = true;
          content.blocking.method = "both";
          content.blocking.adblock.lists = [
            "https://easylist.to/easylist/easylist.txt"
            "https://easylist.to/easylist/easyprivacy.txt"
            "https://ublockorigin.pages.dev/filters/filters.txt"
          ];
          content.javascript.enabled = true;

          # 📐 Compact UI Layout
          tabs.position = "top";
          tabs.show = "multiple"; # Hide tab bar when only 1 tab is open for minimal UI
          tabs.padding = {
            top = 2;
            bottom = 2;
            left = 6;
            right = 6;
          };
          statusbar.show = "in-mode"; # Compact UI: Show statusbar only in command/insert mode
          statusbar.position = "bottom";
          scrolling.smooth = true;
        };

        # 🔑 Custom Keybindings for Bitwarden, Raindrop, Downloads & Extension Features
        keyBindings = {
          normal = {
            # Bitwarden Password Manager Integration
            "zb" = "spawn --userscript qute-bitwarden";
            "zB" = "spawn --userscript qute-bitwarden --password-only";

            # Raindrop.io Bookmark Manager Integration
            "zr" = "open -t https://raindrop.io/app/bookmark/add?url={url}";

            # External Download Manager (Aria2c / System prompt)
            "xD" = "spawn --userscript open_download";
            "xa" = "hint links spawn aria2c -d ${config.home.homeDirectory}/Downloads {hint-url}";
          };
        };

        # 🎨 Styling & Theme Adjustments
        extraConfig = ''
          # Accept cookies automatically
          config.set('content.cookies.accept', 'all', 'chrome-devtools://*')

          # Enable smooth scrolling
          config.set('scrolling.smooth', True)
        '';
      };
    };
  };
}
