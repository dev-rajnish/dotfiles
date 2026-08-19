# =============================================================================
#  Shell Integration & Modern CLI Tools
# =============================================================================
{
  programs = {
    # Pure Bare-Minimum Bash (With Shoelace dynamic hooks)
    bash = {
      enable = true;
      initExtra = ''
        [[ -f ~/.config/shell/sl_env.bash ]] && source ~/.config/shell/sl_env.bash
        [[ -f ~/.config/shell/sl_alias.bash ]] && source ~/.config/shell/sl_alias.bash
      '';
    };

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
