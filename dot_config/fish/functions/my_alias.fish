# =============================================================================
#  Fish Custom Shell Aliases
# =============================================================================

function my_alias
    # Directory Navigation Shortcuts
    alias .f="cd ~/.config/fish/"
    alias .c="cd ~/_ws/dotfiles/dot_config/"
    alias .l="cd ~/.local/"
    alias .b="cd ~/.local/bin/"
    alias .s="cd ~/.local/share/"
    alias .d="cd ~/_ws/dotfiles/"
    alias .w="cd ~/walls/"
    alias rs="cd ~/_ws/code/rs"
    alias .h="cd ~/_ws/dotfiles/home-manager/"

    # Environment & Utilities
    alias dev=dev_env
    alias q="exit"

    # misc
    alias c="clear"
    #alias nvim="fhs-env nvim"

    # home-manager and nixos
    alias hms="nix run .#homeConfigurations.rsh.activationPackage"

    # cli tools and Utilities
    alias h="herdr"
    alias cmatrix="cmatrix -C blue"
    alias glow="glow -t"

end
