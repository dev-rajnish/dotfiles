# =============================================================================
#  NixOS Core Shell Configuration (Pure Bash Default)
# =============================================================================
{pkgs, ...}: {
  # 🐚 System-Wide Pure Bash Configuration
  programs.bash = {
    enable = true;
    completion.enable = true;
  };

  # Set default system and login shell to pure Bash
  users.defaultUserShell = pkgs.bash;

  # Available valid login shells
  environment.shells = with pkgs; [
    bash
  ];
}
