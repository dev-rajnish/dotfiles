# =============================================================================
#  Zen Browser Beta & Catppuccin Theme Integration
# =============================================================================
{
  pkgs,
  inputs,
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
    setAsDefaultBrowser = true;

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
  };
}
