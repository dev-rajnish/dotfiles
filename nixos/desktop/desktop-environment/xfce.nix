{
  pkgs,
  config,
  env,
  ...
}: {
  services.xserver.desktopManager.lxqt.enable = true;
}
