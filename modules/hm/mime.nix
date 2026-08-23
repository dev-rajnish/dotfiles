{
  config,
  pkgs,
  lib,
  env,
  ...
}: let
  cfg = config.mySystem.hm.mime;
in {
  options.mySystem.hm.mime = {
    enable = lib.mkEnableOption "imperative mime apps management via handlr-regex";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = {
      config,
      pkgs,
      ...
    }: {
      home.packages = [pkgs.handlr-regex];

      # Imperative MIME management via handlr-regex (keeping ~/.config/mimeapps.list mutable)
      xdg.mimeApps.enable = false;
    };
  };
}
