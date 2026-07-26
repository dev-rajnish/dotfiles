{pkgs, ...}: {
  home.packages = with pkgs; [
    nwg-displays
    process-viewer
    nwg-clipman
  ];
}
