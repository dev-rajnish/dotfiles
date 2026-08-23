{
  config,
  lib,
  pkgs,
  env,
  ...
}: let
  cfg = config.mySystem.systemd-services.wayle;
in {
  options.mySystem.systemd-services.wayle = {
    enable = lib.mkEnableOption "wayle status bar systemd user service";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = {
      config,
      pkgs,
      ...
    }: {
      systemd.user.services.wayle = {
        Unit = {
          Description = "Wayle Wayland Status Bar & System Overlay Daemon";
          Documentation = ["https://github.com/dev-rajnish/wayle"];
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target" "niri.service"];
          Requisite = ["graphical-session.target"];
        };
        Service = {
          Type = "simple";
          ExecStart = "%h/.local/bin/wayle";
          Restart = "on-failure";
          RestartSec = 1;
        };
        Install = {
          WantedBy = ["graphical-session.target" "graphical.target"];
        };
      };
    };
  };
}
