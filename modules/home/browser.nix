# =============================================================================
#  Home Manager Web Browsers Module (modules/home/browser.nix)
#  Customized Firefox Developer Edition (Default), Zen Browser & Browser Suite
# =============================================================================
{
  config,
  lib,
  pkgs,
  inputs,
  env,
  ...
}: {
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  # ---------------------------------------------------------------------------
  # 🦊 Firefox Developer Edition (Primary Default Browser)
  # ---------------------------------------------------------------------------
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;
    nativeMessagingHosts = [
      pkgs.firefoxpwa
    ];

    # Enterprise Policies for Global Privacy & Telemetry Hardening
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
    };

    profiles.default = {
      id = 0;
      name = "dev-edition-default";
      isDefault = true;

      # Declarative Extension Management via Rycee Addons
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin
        raindropio
        bitwarden
        pwas-for-firefox
      ];

      # DuckDuckGo Search Engine
      search = {
        default = "DuckDuckGo";
        privateDefault = "DuckDuckGo";
        force = true;
        order = ["DuckDuckGo"];
      };

      # Detailed Profile Preferences
      settings = {
        # Extension installation confirmation bypass
        "extensions.autoDisableScopes" = 0;

        # Search preferences
        "browser.search.defaultenginename" = "DuckDuckGo";
        "browser.urlbar.placeholderName" = "DuckDuckGo";

        # Native Vertical Tabs & Modern Sidebar
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;

        # Fullscreen API & Instant Transitions
        "full-screen-api.enabled" = true;
        "full-screen-api.warning.timeout" = 0;
        "full-screen-api.warning.delay" = 0;
        "full-screen-api.transition-duration.enter" = "0 0";
        "full-screen-api.transition-duration.leave" = "0 0";

        # Complete Telemetry & Tracking Disabling
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "experiments.supported" = false;
        "experiments.enabled" = false;
        "experiments.manifest.uri" = "";
        "browser.ping-centre.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "app.shield.optoutstudies.enabled" = false;
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

        # Memory Cache Performance Optimization
        "browser.sessionstore.interval" = 1800000;
        "browser.cache.disk.enable" = false;
        "browser.cache.memory.enable" = true;
        "browser.cache.memory.capacity" = 524288;
      };
    };
  };

  # ---------------------------------------------------------------------------
  # 🌊 Zen Browser Beta (Secondary Modern Browser)
  # ---------------------------------------------------------------------------
  programs.zen-browser = {
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

  # ---------------------------------------------------------------------------
  # 🌐 User Browser Packages & Tools
  # ---------------------------------------------------------------------------
  home.packages = with pkgs; [
    firefoxpwa
    google-chrome
    chromium
    tor-browser
  ];
}
