# =============================================================================
#  Declarative LibreWolf Browser Packaging & Customization
# =============================================================================
{
  pkgs,
  lib,
  ...
}: let
  # ---------------------------------------------------------------------------
  # 🦊 Custom Wrapped LibreWolf with Extensions, GPU VA-API & Cookie Retention
  # ---------------------------------------------------------------------------
  customLibrewolf = pkgs.wrapFirefox pkgs.librewolf-unwrapped {
    wmClass = "LibreWolf";
    libName = "librewolf";

    # Native messaging hosts for extensions (Tridactyl & FirefoxPWA)
    nativeMessagingHosts = with pkgs; [
      tridactyl-native
      firefoxpwa
    ];

    # Daily-Driver Performance & UI Preferences (about:config)
    extraPrefs = ''
      // GPU Acceleration & Hardware Video Decoding (AMD Rembrandt / Radeon 680M)
      pref("gfx.webrender.all", true);
      pref("gfx.canvas.accelerated", true);
      pref("layers.acceleration.force-enabled", true);
      pref("media.ffmpeg.vaapi.enabled", true);
      pref("media.rdd-v4l2.enabled", false);
      pref("media.av1.enabled", true);

      // Wayland & Portal Integration
      pref("widget.use-xdg-desktop-portal.file-picker", 1);
      pref("widget.use-xdg-desktop-portal.mime-handler", 1);
      pref("general.autoScroll", true);

      // ⚡ SSD Protection: 30-Minute Session Write Interval & RAM-Only Caching
      pref("browser.sessionstore.interval", 1800000); // 30 minutes (1,800,000 ms) instead of 15s
      pref("browser.cache.disk.enable", false);        // Zero SSD disk cache
      pref("browser.cache.memory.enable", true);
      pref("browser.cache.memory.capacity", 524288);   // 512MB RAM cache
      pref("browser.pagethumbnails.capturing_disabled", true);
      pref("browser.helperApps.deleteTempFileOnExit", true);

      // Usability: Keep session logins & cookies for ALL websites on browser close
      pref("privacy.sanitize.sanitizeOnShutdown", false);
      pref("privacy.clearOnShutdown.cookies", false);
      pref("privacy.clearOnShutdown.cache", false);
      pref("privacy.clearOnShutdown.history", false);
      pref("privacy.clearOnShutdown.sessions", false);
      pref("privacy.clearOnShutdown.downloads", false);
      pref("privacy.clearOnShutdown.offlineApps", false);
      pref("privacy.clearOnShutdown.siteSettings", false);
      pref("privacy.clearOnShutdown.openWindows", false);

      pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);
      pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", false);
      pref("privacy.clearOnShutdown_v2.cache", false);
      pref("privacy.clearOnShutdown_v2.siteSettings", false);

      // Keep cookies normally until they naturally expire
      pref("network.cookie.lifetimePolicy", 0);

      // Fingerprinting Protection with system dark theme & timezone support
      pref("privacy.resistFingerprinting", false);
      pref("privacy.fingerprintingProtection", true);
      pref("privacy.fingerprintingProtection.overrides", "+allTargets,-CSSPrefersColorScheme,-JSDateTimeUTC");

      // General UI & Quality of Life
      pref("browser.aboutConfig.showWarning", false);
      pref("browser.shell.checkDefaultBrowser", false);
      pref("browser.tabs.insertRelatedAfterCurrent", true);
      pref("browser.tabs.warnOnClose", false);
      pref("extensions.autoDisableScopes", 0);
      pref("extensions.install_origins.enabled", true);
      pref("middlemouse.paste", false);
    '';

    # Enterprise Policies for auto-installing extensions and security defaults
    extraPolicies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;

      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      # Declarative Extensions (Auto-installed from Mozilla Addons)
      ExtensionSettings = {
        # 1. Tridactyl (Vim keybindings)
        "tridactyl.vim@cmc.re" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/tridactyl-vim/latest.xpi";
          installation_mode = "force_installed";
        };

        # 2. Raindrop.io (Bookmark manager)
        "jid0-adyhmvsP91nUO8TmFake1MnfA@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/raindropio/latest.xpi";
          installation_mode = "force_installed";
        };

        # 3. Progressive Web Apps (PWA) for Firefox
        "firefoxpwa@filips.si" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/pwas-for-firefox/latest.xpi";
          installation_mode = "force_installed";
        };

        # 4. Enhancer for YouTube
        "enhancerforyoutube@maximerf.addons.mozilla.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/enhancer-for-youtube/latest.xpi";
          installation_mode = "force_installed";
        };

        # 5. uBlock Origin (Ad & Tracker blocker)
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };

        # 6. Bitwarden (Password Manager)
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };

        # 7. Dark Reader (Dark mode for web pages)
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
        };
      };

      # Never sanitize data or clear cookies on shutdown for any website
      SanitizeOnShutdown = false;
      Cookies = {
        ExpireAtSessionEnd = false;
      };
    };
  };
in {
  home.packages = [
    customLibrewolf
  ];
}
