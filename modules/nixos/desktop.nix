# =============================================================================
#  Desktop Integration & Services Module (modules/nixos/desktop.nix)
#  Manages core desktop services, Polkit security rules, and XDG portals
# =============================================================================
{
  config,
  lib,
  pkgs,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🌐 Core Desktop Services (Niri, Thunar, GVFS, Flatpak, Direnv)
  # ---------------------------------------------------------------------------
  environment.variables = {
    MAN_DISABLE_CACHE = 1;
  };

  environment.systemPackages = with pkgs; [
    shoelace-bin
    xdg-utils
    polkit_gnome
    gnome-keyring
    libsecret
    seahorse
    gcr
  ];

  programs = {
    dconf.enable = true;
    niri.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  services.flatpak.enable = true;
  services.gvfs.enable = true;
  services.envfs.enable = true;
  services.tumbler.enable = true;

  # ---------------------------------------------------------------------------
  # 🛡️ Polkit Security Rules & GNOME Keyring Integration
  # ---------------------------------------------------------------------------
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        if (action.id.indexOf("org.freedesktop.secrets") === 0 ||
            action.id.indexOf("org.freedesktop.secret") === 0 ||
            action.id.indexOf("org.gnome.keyring") === 0) {
          return polkit.Result.YES;
        }
        if (action.id == "org.freedesktop.udisks2.filesystem-mount" ||
            action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
            action.id == "org.freedesktop.udisks2.encrypted-unlock" ||
            action.id == "org.freedesktop.udisks2.eject-media") {
          return polkit.Result.YES;
        }
      }
    });
  '';

  services.gnome.gnome-keyring.enable = true;

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
  # 🪟 XDG Desktop Portals Engine
  # ---------------------------------------------------------------------------
  xdg.portal = {
    enable = true;
    wlr.enable = false;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];

    config = {
      common = {
        default = lib.mkDefault ["gtk"];
      };
      niri = {
        default = lib.mkForce ["gnome" "gtk"];
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
        "org.freedesktop.impl.portal.OpenURI" = "gtk";
        "org.freedesktop.impl.portal.AppChooser" = "gtk";
        "org.freedesktop.impl.portal.Settings" = "gtk";
      };
    };
  };
}
