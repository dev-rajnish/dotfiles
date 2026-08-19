# =============================================================================
#  NixOS Core Shell Configuration (Pure Bash Default)
# =============================================================================
{pkgs, ...}: {
  # 🐚 System-Wide Shell Configuration
  programs.fish.enable = true;
  programs.bash = {
    enable = true;
    completion.enable = true;
  };

  # Set default system and login shell to Fish
  users.defaultUserShell = pkgs.fish;

  # Available valid login shells
  environment.shells = with pkgs; [
    fish
    bash
  ];
}
