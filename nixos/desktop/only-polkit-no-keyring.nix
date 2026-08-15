# =============================================================================
#  Polkit Privilege Elevation & Authentication Agent (No GNOME Keyring)
# =============================================================================
{pkgs, ...}: {
  # ---------------------------------------------------------------------------
  # 🛡️ Enable Polkit System-Wide
  # ---------------------------------------------------------------------------
  security.polkit.enable = true;

  # ---------------------------------------------------------------------------
  # 📁 Polkit Rules: Passwordless Udisks2 Disk Mounting for Wheel Users
  # ---------------------------------------------------------------------------
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.udisks2.filesystem-mount" ||
           action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
           action.id == "org.freedesktop.udisks2.encrypted-unlock" ||
           action.id == "org.freedesktop.udisks2.eject-media") &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
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
  # 📦 System Packages (Polkit GUI Agent)
  # ---------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    polkit_gnome
  ];

  # Note: GNOME Keyring is deliberately kept disabled to prevent login/browser popup prompts
  # services.gnome.gnome-keyring.enable = false;
}
