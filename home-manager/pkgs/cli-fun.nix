{pkgs, ...}: {
  home.packages = with pkgs; [
    pipes
    cmatrix
    # oneko
    cbonsai
    toilet
    fortune
    lolcat
  ];
}
