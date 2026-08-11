{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    nativeMessagingHosts = [pkgs.firefoxpwa];

    # Catppuccin Mocha theme preset
    profiles.default.presets.catppuccin = {
      enable = true;
      flavor = "Mocha";
      accent = "Mauve";
    };

    # Betterfox performance preset
    profiles.default.presets.betterfox.enable = false;

    # Arkenfox hardening preset
    profiles.default.presets.arkenfox.enable = false;
  };
}
