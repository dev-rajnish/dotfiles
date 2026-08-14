# =============================================================================
#  System Fonts & Linux TTY Console Typography
# =============================================================================
{pkgs, ...}: {
  # ---------------------------------------------------------------------------
  # 1. 🖥️ Linux Virtual Console / TTY Font Configuration
  # ---------------------------------------------------------------------------
  console = {
    enable = true;
    packages = [pkgs.terminus_font];
    font = "ter-v28b"; # HiDPI Terminus bitmap font for crisp TTY readability
  };

  # ---------------------------------------------------------------------------
  # 2. 🔤 Desktop & Application Fonts
  # ---------------------------------------------------------------------------
  fonts = {
    fontconfig.enable = true;
    fontDir.enable = true;

    packages =
      # Nerd Fonts for developer glyphs and symbols
      (with pkgs.nerd-fonts; [
        fira-code
        hack
        jetbrains-mono
        symbols-only
        victor-mono
      ])
      # General & Emoji Fonts
      ++ (with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
        font-awesome
      ]);
  };
}
