# =============================================================================
#  Systemd User Service: swaybg (Wallpaper Daemon)
# =============================================================================
{
  pkgs,
  lib,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🖼️ Swaybg User Service
  # ---------------------------------------------------------------------------
  systemd.user.services.swaybg = {
    Unit = {
      Description = "Swaybg Wallpaper Daemon for Wayland Session";
      Documentation = ["man:swaybg(1)"];
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target" "niri.service"];
      Requisite = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.writeShellScript "swaybg-start" ''
        if [ -f "$HOME/.config/background" ]; then
          exec ${pkgs.swaybg}/bin/swaybg -i "$HOME/.config/background" -m fill
        else
          exec ${pkgs.swaybg}/bin/swaybg -c "#191724"
        fi
      ''}";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install = {
      WantedBy = ["graphical-session.target" "graphical.target"];
    };
  };
}
