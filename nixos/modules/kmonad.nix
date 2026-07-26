{
  pkgs,
  username,
  keyboard-path,
  ...
}: let
  kbdpath = "${keyboard-path}";
in {
  environment.systemPackages = with pkgs; [
    kmonad
  ];

  hardware.uinput.enable = true;
  services.udev.extraRules = ''KERNEL=="uinput", OWNER="${username}",MODE="0600" '';
  users.users.${username}.extraGroups = ["input"];

  services.kmonad = {
    enable = true;
    package = pkgs.kmonad;

    keyboards."my-laptop" = {
      device = kbdpath;
    config = builtins.readFile ./kmonad-config.kbd;

    };
  };
}
