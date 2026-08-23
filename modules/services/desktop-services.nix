{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.mySystem.services.desktop-services;
in {
  options.mySystem.services.desktop-services = {
    enable = lib.mkEnableOption "desktop-services config";
  };

  config = lib.mkIf cfg.enable {
    # ---------------------------------------------------------------------------
    # 🌐 System-wide Environment Variables & Packages
    # ---------------------------------------------------------------------------
    environment.variables = {
      MAN_DISABLE_CACHE = 1; # Disable man cache regeneration for faster rebuilds
    };

    environment.systemPackages = [
      (pkgs.runCommandLocal "shoelace-bin" {} ''
        mkdir -p $out/bin
        cp -a ${../../bin}/* $out/bin/
        chmod +x $out/bin/*
      '')
    ];

    # ---------------------------------------------------------------------------
    # 🛠️ System Program Enablements & Integrations
    # ---------------------------------------------------------------------------
    programs = {
      # dconf system service required for GTK / HM dconf.settings
      dconf.enable = true;

      # Niri Wayland scrollable-tiling compositor
      niri.enable = true;

      # Thunar File Manager & Plugin Extensions
      thunar = {
        enable = true;
        plugins = with pkgs; [
          thunar-archive-plugin
          thunar-volman
          thunar-media-tags-plugin
        ];
      };

      # Direnv shell environment loader
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };

    # ---------------------------------------------------------------------------
    # 🛠️ System Services Enablements & Integrations
    # ---------------------------------------------------------------------------
    # Flatpak application sandboxing
    services.flatpak.enable = true;

    # Mounting, trash, and filesystem abstractions for Thunar
    services.gvfs.enable = true;
    services.envfs.enable = true;

    # D-Bus Thumbnailer service (images, pdfs, videos)
    services.tumbler.enable = true;
  };
}
