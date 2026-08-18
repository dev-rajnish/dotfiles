# =============================================================================
#  Shell Integration & Modern CLI Tools
# =============================================================================
{
  # ---------------------------------------------------------------------------
  # 🐚 Pure Bare-Minimum Shell Configuration
  # ---------------------------------------------------------------------------
  programs = {
    # Pure Bare-Minimum Bash (No custom rc or prompt hooks)
    bash.enable = true;

    # CLI Utilities (Standalone usage)
    atuin.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    eza.enable = true;
    zoxide.enable = true;
  };
}
