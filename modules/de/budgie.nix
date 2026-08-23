{
  config,
  lib,
  pkgs,
  env,
  ...
}: let
  cfg = config.mySystem.de.budgie;
in {
  options.mySystem.de.budgie = {
    enable = lib.mkEnableOption "budgie config";
  };

  config = lib.mkIf cfg.enable (
    let
      enableBudgie = env.enableBudgie or false;
    in {
      #services.server.enable = lib.mkIf enableBudgie true;
      services.desktopManager.budgie = lib.mkIf enableBudgie {
        enable = true;
        extraPlugins = with pkgs; [
          budgie-analogue-clock-applet
        ];
      };
    }
  );
}
