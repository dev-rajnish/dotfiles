{pkgs, ...}: {
  # XDG Desktop Portals Configuration
  xdg.portal = {
    enable = true;
    wlr.enable = false; # Gnome portal used for Niri
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
      };
      niri = {
        default = ["gnome" "gtk"];
        "org.freedesktop.impl.portal.Screencast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
      };
    };
  };

  # Portal Utilities
  environment.systemPackages = with pkgs; [
    xdg-utils
  ];
}
