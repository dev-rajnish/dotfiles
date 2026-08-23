{
  config,
  lib,
  pkgs,
  env,
  ...
}: let
  cfg = config.mySystem.systemd-services.polkit-gnome;
in {
  options.mySystem.systemd-services.polkit-gnome = {
    enable = lib.mkEnableOption "polkit GNOME authentication agent user service";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = {
      config,
      pkgs,
      ...
    }: {
      systemd.user.services.polkit-gnome-authentication-agent-1 = {
        Unit = {
          Description = "Polkit GNOME Authentication Agent";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
    };
  };
}
