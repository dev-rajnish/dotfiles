{
  config,
  lib,
  pkgs,
  env,
  ...
}: let
  cfg = config.mySystem.de.xfce;
in {
  options.mySystem.de.xfce = {
    enable = lib.mkEnableOption "xfce config";
  };

  config = lib.mkIf cfg.enable (
    let
      enableXfce = env.enableXfce or false;
    in {
      services.xserver = lib.mkIf enableXfce {
        enable = true;
        desktopManager.lxqt.enable = true;
      };
    }
  );
}
