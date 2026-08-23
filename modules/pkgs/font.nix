# =============================================================================
#  Fonts & Typography Module
#  Auto-generated from tokens/pkgs/fonts.toml via MiniJinja (bin/pkg-render)
# =============================================================================
{pkgs, ...}: {
  fonts = {
    fontconfig.enable = true;
    fontDir.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      inter
      noto-fonts-color-emoji
    ];
  };
}
