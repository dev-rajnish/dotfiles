{pkgs, ...}: {
  home.packages = with pkgs; [
    cbonsai
    cmatrix
    fortune
    lolcat
    pipes
    toilet
  ];
}
