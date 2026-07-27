# =============================================================================
#  Fish Custom Shell Aliases
# =============================================================================

function my_alias
    # Directory Navigation Shortcuts
    alias .f="cd ~/.config/fish/"
    alias .c="cd ~/.config/"
    alias .l="cd ~/.local/"
    alias .b="cd ~/.local/bin/"
    alias .s="cd ~/.local/share/"
    alias .d="cd ~/Downloads/"
    alias .w="cd ~/walls/"

    # Environment & Utilities
    alias dev=dev_env
    alias q="exit"
end
