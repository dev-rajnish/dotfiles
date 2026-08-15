# =============================================================================
#  XDG Desktop Portals Configuration (Wayland Desktop Integration)
# =============================================================================
{
  pkgs,
  lib,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🪟 XDG Desktop Portals Engine
  # ---------------------------------------------------------------------------
  xdg.portal = {
    enable = true;
    wlr.enable = false; # GNOME portal backend used for Niri

    # Desktop portal backends
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];

    # Portal routing rules for Niri Wayland Compositor
    config = {
      common = {
        default = lib.mkDefault ["gtk"];
      };
      niri = {
        default = lib.mkForce ["gnome" "gtk"];
        # Screen casting & recording via GNOME portal backend
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        # Dialogs, Pickers & App settings via GTK portal backend
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
        "org.freedesktop.impl.portal.OpenURI" = "gtk";
        "org.freedesktop.impl.portal.AppChooser" = "gtk";
        "org.freedesktop.impl.portal.Settings" = "gtk";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # 🧰 Portal Command-Line Utilities
  # ---------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    xdg-utils
  ];
}
