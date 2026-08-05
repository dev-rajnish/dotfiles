# =============================================================================
#  Fish Custom Shell Aliases
# =============================================================================

function my_alias
    # Directory Navigation Shortcuts
    alias .f="cd ~/.config/fish/"
    alias .c="cd ~/ws/dotfiles/dot_config/"
    alias .l="cd ~/.local/"
    alias .b="cd ~/.local/bin/"
    alias .s="cd ~/.local/share/"
    alias .d="cd ~/Downloads/"
    alias .w="cd ~/walls/"
    alias rs="cd ~/ws/code/rs"
    alias .h="cd ~/ws/dotfiles/home-manager/"

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

end
