{pkgs, ...}: {
  home.packages = with pkgs; [
    wl-clipboard
    nwg-clipman
    cliphist
    #clipman
  ];
}
