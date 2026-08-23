{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.mySystem.services.polkit;
in {
  options.mySystem.services.polkit = {
    enable = lib.mkEnableOption "polkit config";
  };

  config = lib.mkIf cfg.enable {
    # ---------------------------------------------------------------------------
    # 🛡️ Enable Polkit System-Wide
    # ---------------------------------------------------------------------------
    security.polkit.enable = true;

    # ---------------------------------------------------------------------------
    # 📁 Polkit Rules: Passwordless Udisks2 & Secret Service for Wheel Users
    # ---------------------------------------------------------------------------
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.isInGroup("wheel")) {
          // Auto-allow secret service and credential store queries without popup prompt
          if (action.id.indexOf("org.freedesktop.secrets") === 0 ||
              action.id.indexOf("org.freedesktop.secret") === 0 ||
              action.id.indexOf("org.gnome.keyring") === 0) {
            return polkit.Result.YES;
          }

          // Auto-allow udisks2 filesystem mounting, unlocking and ejecting
          if (action.id == "org.freedesktop.udisks2.filesystem-mount" ||
              action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
              action.id == "org.freedesktop.udisks2.encrypted-unlock" ||
              action.id == "org.freedesktop.udisks2.eject-media") {
            return polkit.Result.YES;
          }
        }
      });
    '';

    # ---------------------------------------------------------------------------
    # 🔑 GNOME Keyring Daemon & Secret Service Integration
    # ---------------------------------------------------------------------------
    services.gnome.gnome-keyring.enable = true;

    # ---------------------------------------------------------------------------
    # 🔓 PAM Keyring Unlocking on User Login & Autologin
    # ---------------------------------------------------------------------------
    security.pam.services = {
      login.enableGnomeKeyring = true;
      ly.enableGnomeKeyring = true;
      niri.enableGnomeKeyring = true;
      autologin.enableGnomeKeyring = true;
      greetd.enableGnomeKeyring = true;
      greetd-autologin.enableGnomeKeyring = true;
      tuigreet.enableGnomeKeyring = true;
      sddm.enableGnomeKeyring = true;
      gdm.enableGnomeKeyring = true;
      gdm-autologin.enableGnomeKeyring = true;
      lightdm.enableGnomeKeyring = true;
      swaylock = {};
    };

    # ---------------------------------------------------------------------------
    # 📦 System Packages (Polkit GUI Agent & Keyring Management)
    # ---------------------------------------------------------------------------
    environment.systemPackages = with pkgs; [
      polkit_gnome
      gnome-keyring
      libsecret
      seahorse
      gcr
    ];
  };
}
