{
  config,
  lib,
  pkgs,
  env,
  ...
}: let
  cfg = config.mySystem.display-manager.gdm;
in {
  options.mySystem.display-manager.gdm = {
    enable = lib.mkEnableOption "gdm config";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager = {
      gdm = {
        enable = true;
        autoSuspend = false;
        settings.debug.enable = false;
      };
      defaultSession = "niri";
    };
  };
}
