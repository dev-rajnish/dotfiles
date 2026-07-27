{pkgs, ...}: {
  services = {
    #wallpaper daemon
    awww.enable = true;

    swayosd.enable = true;
  };

  programs = {
    atuin.enable = true;
    fuzzel.enable = true;
  };

  home.packages = with pkgs; [
    #wallpaoer
    waypaper
    wallust

    #brightness
    brightnessctl

    #volume player
    pamixer
    playerctl

    #lockscreen
    swaylock-effects
    swayidle

    #panel
    waybar

    #clipboard
    wl-clipboard
    nwg-clipman
    cliphist

    #screenshot
    grim
    slurp
  ];
}
