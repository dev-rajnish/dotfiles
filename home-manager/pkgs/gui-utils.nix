{pkgs, ...}: {
  home.packages = with pkgs; [
    celluloid
    fuzzel
    gimp
    librewolf-bin-unwrapped
    nwg-displays
    process-viewer
    qutebrowser
    zathura
  ];
}
