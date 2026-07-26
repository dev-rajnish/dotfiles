{pkgs, ...}: {
  home.packages = with pkgs; [
  ];

  # Install
  programs.firefox.enable = true;
}
