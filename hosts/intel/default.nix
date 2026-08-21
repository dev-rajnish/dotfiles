{ config, pkgs, env, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = env.stateVersion;
  home-manager.users.${env.username}.home.stateVersion = env.stateVersion;

  # Boot & Kernel
  mySystem.system.boot-and-kernel.enable = true;
  mySystem.system.networking.enable = true;
  mySystem.system.nix-settings.enable = true;
  mySystem.system.time-and-locale.enable = true;
  mySystem.system.user-accounts.enable = true;
  mySystem.system.cache-storage.enable = true;

  # Hardware
  mySystem.hardware.intel.enable = true; # Changed from AMD
  mySystem.hardware.bluetooth.enable = true;
  mySystem.hardware.power.enable = true;

  # Services & Display
  mySystem.services.desktop-services.enable = true;
  mySystem.services.kanata.enable = true;
  mySystem.services.polkit.enable = true;
  mySystem.services.xdg-portals.enable = true;
  mySystem.display-manager.tuigreet.enable = true;

  # Environment & Packages
  mySystem.hm.environment.enable = true;
  mySystem.hm.git.enable = true;
  mySystem.hm.mime.enable = true;
  mySystem.hm.packages.enable = true;
  mySystem.hm.symlinks.enable = true;

  # WM & Apps
  mySystem.wm.wayle.enable = true;
  mySystem.wm.swaybg.enable = true;
  mySystem.wm.wl-clipboard.enable = true;

  mySystem.apps.zen-browser.enable = true;
  mySystem.apps.helium.enable = true;
  mySystem.apps.antigravity.enable = true;

  # Theme
  mySystem.theme.stylix-system.enable = true;
  mySystem.theme.stylix-hm.enable = true;
}
