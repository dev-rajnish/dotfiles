{ env,  config, 
  pkgs,
  lib,
  ...
}:
let
  cfg = config.mySystem.wm.wl-clipboard;
in {
  options.mySystem.wm.wl-clipboard = {
    enable = lib.mkEnableOption "wl-clipboard config";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = { config, ... }: (
    {
  # ---------------------------------------------------------------------------
  # 📋 Install Clipboard Utilities
  # ---------------------------------------------------------------------------
  home.packages = with pkgs; [
    wl-clipboard
    cliphist
  ];

  # ---------------------------------------------------------------------------
  # 🔄 Persistent Clipboard Daemons
  # ---------------------------------------------------------------------------
  systemd.user.services = {
    # 1. Text Clipboard History Store
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

    # 2. Image Clipboard History Store
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
}
  );
  };
}
