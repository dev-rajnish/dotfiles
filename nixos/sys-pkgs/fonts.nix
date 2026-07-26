{pkgs, ...}: {
  fonts.packages = [
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.symbols-only
    pkgs.nerd-fonts.victor-mono
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
