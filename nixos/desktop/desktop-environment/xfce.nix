{
  pkgs,
  config,
  env,
  ...
}: {
  services.xserver.desktopManager.xfce.enable = false;
}
