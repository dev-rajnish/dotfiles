{pkgs, ...}: {
  fonts = {
    fontconfig.enable = true;
    fontDir.enable = true;
    packages =
      (with pkgs.nerd-fonts; [
        fira-code
        hack
        jetbrains-mono
        symbols-only
        victor-mono
      ])
      ++ (with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
        font-awesome
      ]);
  };
}
