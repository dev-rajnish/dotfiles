{
  env,
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.mySystem.apps.zen-browser;
in {
  options.mySystem.apps.zen-browser = {
    enable = lib.mkEnableOption "zen-browser config";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = {
      config,
      pkgs,
      ...
    }: {
      # Import Zen Browser Home Manager module from flake input
      imports = [
        inputs.zen-browser.homeModules.beta
      ];

      # ---------------------------------------------------------------------------
      # 🌐 Zen Browser Configuration
      # ---------------------------------------------------------------------------
      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = false;

        # Progressive Web Apps (PWA) native messaging host
        nativeMessagingHosts = [pkgs.firefoxpwa];

        # Catppuccin Mocha theme preset
        profiles.default.presets.catppuccin = {
          enable = true;
          flavor = "Mocha";
          accent = "Mauve";
        };

        # Betterfox performance preset (Disabled for default stability)
        profiles.default.presets.betterfox.enable = false;

        # Arkenfox hardening preset (Disabled to prevent site breakages)
        profiles.default.presets.arkenfox.enable = false;

        # ⚡ SSD Protection: 30-Minute Session Write Interval & RAM-Only Caching
        profiles.default.settings = {
          "browser.sessionstore.interval" = 1800000; # 30 minutes
          "browser.cache.disk.enable" = false;
          "browser.cache.memory.enable" = true;
          "browser.cache.memory.capacity" = 524288;
        };
      };
    };
  };
}
