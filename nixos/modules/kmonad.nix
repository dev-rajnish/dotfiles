{
  pkgs,
  username,
  keyboardPath,
  ...
}: {
  environment.systemPackages = [pkgs.kmonad];

  hardware.uinput.enable = true;
  services.udev.extraRules = ''KERNEL=="uinput", OWNER="${username}", MODE="0600"'';
  users.users.${username}.extraGroups = ["input"];

  services.kmonad = {
    enable = true;
    package = pkgs.kmonad;

    keyboards."my-laptop" = {
      device = keyboardPath;
      config = builtins.readFile ./kmonad-config.kbd;
    };
  };
}
