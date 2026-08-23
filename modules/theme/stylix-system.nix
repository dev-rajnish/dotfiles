{
  config,
  pkgs,
  lib,
  env,
  ...
}: let
  cfg = config.mySystem.theme.stylix-system;
in {
  options.mySystem.theme.stylix-system = {
    enable = lib.mkEnableOption "stylix-system config";
  };

  config = lib.mkIf cfg.enable (
    let
      theme = env.theme or "rose-pine";
      polarity = env.polarity or "dark";

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
      # 🎨 NixOS System-Level Stylix Configuration
      # ---------------------------------------------------------------------------
      stylix = {
        enable = true;
        enableReleaseChecks = false;
        autoEnable = false;
        polarity = polarity;
        base16Scheme = schemeFile;
      };
    }
  );
}
