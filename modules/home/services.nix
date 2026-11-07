# =============================================================================
#  Home Manager User Systemd Services
#  Manages user session daemons (clipboard, wallpaper, bar, keyring, auth agent)
# =============================================================================
{pkgs, ...}: {
  systemd.user.services = {
    # ---------------------------------------------------------------------------
    # 📋 Cliphist Clipboard Manager
    # ---------------------------------------------------------------------------
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

    # ---------------------------------------------------------------------------
    # 📊 Wayle Status Bar Daemon
    # ---------------------------------------------------------------------------
    wayle = {
      Unit = {
        Description = "Wayle Wayland Status Bar & System Overlay Daemon";
        Documentation = ["https://github.com/dev-rajnish/wayle"];
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target" "niri.service"];
        Requisite = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.wayle}/bin/wayle";
        Restart = "on-failure";
        RestartSec = 1;
      };
      Install = {
        WantedBy = ["graphical-session.target" "graphical.target"];
      };
    };

    # ---------------------------------------------------------------------------
    # 🔐 Polkit GNOME Authentication Agent
    # ---------------------------------------------------------------------------
    polkit-gnome-authentication-agent-1 = {
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

    # ---------------------------------------------------------------------------
    # 🔑 GNOME Keyring Unlock Daemon
    # ---------------------------------------------------------------------------
    gnome-keyring-unlock = {
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
}
