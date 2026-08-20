# =============================================================================
#  Polkit Privilege Elevation & GNOME Keyring PAM Unlock Service
# =============================================================================
{pkgs, ...}: {
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
  # 🔐 GUI Polkit Authentication Agent Service (Prompts only for Root actions)
  # ---------------------------------------------------------------------------
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "Polkit GNOME Authentication Agent";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

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
}
