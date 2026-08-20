# =============================================================================
#  Systemd User Service: wayle (Status Bar & System Overlay Daemon)
# =============================================================================
{
  pkgs,
  lib,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 📊 Wayle Status Bar Daemon Service
  # ---------------------------------------------------------------------------
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
}
