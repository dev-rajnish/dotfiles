{
  config,
  pkgs,
  lib,
  env,
  ...
}: let
  cfg = config.mySystem.hm.environment;
  shoelaceBin = pkgs.runCommandLocal "shoelace-bin" {} ''
    mkdir -p $out/bin
    cp -a ${../../bin}/* $out/bin/
    chmod +x $out/bin/*
  '';
in {
  options.mySystem.hm.environment = {
    enable = lib.mkEnableOption "environment config";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = {
      config,
      pkgs,
      ...
    }: {
      # Suppress Home Manager release news popups
      news.display = "silent";

      home = {
        username = env.username;
        homeDirectory = "/home/${env.username}";
        enableNixpkgsReleaseCheck = true;

        packages = [
          shoelaceBin
          pkgs.dconf
        ];

        # Global User Shell & Editor Session Variables (Populated dynamically from env)
        sessionVariables = {
          EDITOR = env.editor;
          TERMINAL = env.terminal;
          BROWSER = lib.mkDefault env.browser;
          SHELL = "${pkgs.fish}/bin/fish";
          MAN_DISABLE_CACHE = 1;
          SSH_ASKPASS = "";
          GIT_ASKPASS = "";
        };
      };
    };
  };
}
