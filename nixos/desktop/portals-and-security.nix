{pkgs, ...}: {
  # =============================================================================
  #  XDG Desktop Portals (File Chooser, Screen Sharing, Screenshots, Passwords)
  # =============================================================================
  xdg.portal = {
    enable = true;
    wlr.enable = false; # Niri uses xdg-desktop-portal-gnome for screencasting
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = ["gnome" "gtk"];
        "org.freedesktop.impl.portal.Screencast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
        # "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      };
      niri = {
        default = ["gnome" "gtk"];
        "org.freedesktop.impl.portal.Screencast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
        # "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      };
    };
  };

  # =============================================================================
  #  Polkit & Password Prompt Authentication Agent
  # =============================================================================
  # security.polkit.enable = true;
  #
  # # Polkit GUI Authentication Agent user service (for password prompts)
  # systemd.user.services.polkit-gnome-authentication-agent-1 = {
  #   description = "Polkit GNOME Authentication Agent";
  #   wantedBy = ["graphical-session.target"];
  #   wants = ["graphical-session.target"];
  #   after = ["graphical-session.target"];
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
  #     Restart = "on-failure";
  #     RestartSec = 1;
  #     TimeoutStopSec = 10;
  #   };
  # };
  #
  # =============================================================================
  #  GNOME Keyring (Password Store & Secret Portal)
  # =============================================================================
  #services.gnome.gnome-keyring.enable = true;
  #security.pam.services.login.enableGnomeKeyring = true;

  # Additional System Packages for Security & Portals
  environment.systemPackages = with pkgs; [
    # polkit_gnome
    # seahorse
    xdg-utils
  ];
}
