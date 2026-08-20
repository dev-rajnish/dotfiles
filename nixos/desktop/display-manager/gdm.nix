{
  pkgs,
  env,
  ...
}: {
  services.displayManager = {
    gdm = {
      enable = true;
      autoSuspend = false;
      settings.debug.enable = false;
    };
    defaultSession = "niri";
  };
}
