{pkgs, ...}: {
  home.packages = with pkgs; [
    nwg-displays
    process-viewer
    gimp
    celluloid
    zathura
    qutebrowser
  ];
}
