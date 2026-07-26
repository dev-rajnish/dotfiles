{pkgs, ...}: {
  home.packages = with pkgs; [
    #nix-software-center.packages.${system}.nix-software-center
    gimp
    celluloid
  ];
}
