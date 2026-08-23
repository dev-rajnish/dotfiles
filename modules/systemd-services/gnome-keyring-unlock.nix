{
  config,
  lib,
  pkgs,
  env,
  ...
}: let
  cfg = config.mySystem.systemd-services.gnome-keyring-unlock;
in {
  options.mySystem.systemd-services.gnome-keyring-unlock = {
    enable = lib.mkEnableOption "GNOME keyring auto-unlock user service";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = {
      config,
      pkgs,
      ...
    }: {
      systemd.user.services.gnome-keyring-unlock = {
        Unit = {
          Description = "Auto-unlock GNOME Keyring daemon for autologin session";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.writeShellScript "gnome-keyring-unlock-script" ''
            set -eu
            ${pkgs.coreutils}/bin/printf '\n' | ${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --unlock 2>/dev/null || true
            ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd SSH_AUTH_SOCK GNOME_KEYRING_CONTROL
            ${pkgs.systemd}/bin/systemctl --user import-environment SSH_AUTH_SOCK GNOME_KEYRING_CONTROL
          ''}";
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
    };
  };
}
