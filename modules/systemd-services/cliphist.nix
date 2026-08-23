{
  config,
  lib,
  pkgs,
  env,
  ...
}: let
  cfg = config.mySystem.systemd-services.cliphist;
in {
  options.mySystem.systemd-services.cliphist = {
    enable = lib.mkEnableOption "cliphist clipboard history persistence store services";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = {
      config,
      pkgs,
      ...
    }: {
      home.packages = with pkgs; [
        wl-clipboard
        cliphist
      ];

      systemd.user.services = {
        cliphist-text = {
          Unit = {
            Description = "Cliphist Text Clipboard Persistence Store";
            Documentation = ["https://github.com/sentriz/cliphist"];
            PartOf = ["graphical-session.target"];
            After = ["graphical-session.target" "niri.service"];
            Requisite = ["graphical-session.target"];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
            Restart = "on-failure";
            RestartSec = 1;
          };
          Install = {
            WantedBy = ["graphical-session.target" "graphical.target"];
          };
        };

        cliphist-images = {
          Unit = {
            Description = "Cliphist Image Clipboard Persistence Store";
            Documentation = ["https://github.com/sentriz/cliphist"];
            PartOf = ["graphical-session.target"];
            After = ["graphical-session.target" "niri.service"];
            Requisite = ["graphical-session.target"];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
            Restart = "on-failure";
            RestartSec = 1;
          };
          Install = {
            WantedBy = ["graphical-session.target" "graphical.target"];
          };
        };
      };
    };
  };
}
