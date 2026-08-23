{
  config,
  lib,
  pkgs,
  env,
  ...
}: let
  cfg = config.mySystem.keyboard.kanata;
in {
  options.mySystem.keyboard.kanata = {
    enable = lib.mkEnableOption "kanata keyboard remapping service";
  };

  config = lib.mkIf cfg.enable (
    lib.mkIf (env.enableKanata or false) {
      environment.systemPackages = [pkgs.kanata];

      hardware.uinput.enable = true;
      services.udev.extraRules = ''KERNEL=="uinput", OWNER="${env.username}", MODE="0600"'';
      users.users.${env.username}.extraGroups = ["input" "uinput"];

      services.kanata = {
        enable = true;
        package = pkgs.kanata;

        keyboards."default" = {
          devices = [];
          extraArgs = ["--nodelay"];
          extraDefCfg = ''
            process-unmapped-keys yes
            concurrent-tap-hold yes
          '';
          config = builtins.readFile ./kanata.config.kbd;
        };
      };
    }
  );
}
