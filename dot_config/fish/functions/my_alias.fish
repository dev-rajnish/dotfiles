# =============================================================================
#  Fish Custom Shell Aliases
# =============================================================================

function my_alias
    # Directory Navigation Shortcuts
    alias .f="cd ~/.config/fish/"
    alias .l="cd ~/.local/"
    alias .b="cd ~/.local/bin/"
    alias .s="cd ~/.local/share/"

    # Dynamic dotfiles navigation shortcuts
    if test -d ~/_ws/dotfiles
        alias .d="cd ~/_ws/dotfiles/"
        alias .c="cd ~/_ws/dotfiles/dot_config/"
        alias .h="cd ~/_ws/dotfiles/home-manager/"
    else if test -d ~/dotfiles
        alias .d="cd ~/dotfiles/"
        alias .c="cd ~/dotfiles/dot_config/"
        alias .h="cd ~/dotfiles/home-manager/"
    else if test -d ~/.dotfiles
        alias .d="cd ~/.dotfiles/"
        alias .c="cd ~/.dotfiles/dot_config/"
        alias .h="cd ~/.dotfiles/home-manager/"
    end

    if test -d ~/ws/walls
        alias .w="cd ~/ws/walls/"
    else if test -d ~/Pictures/Wallpapers
        alias .w="cd ~/Pictures/Wallpapers/"
    end

    # Environment & Utilities
    alias dev=dev_env
    alias q="exit"

    # misc
    alias c="clear"

    # home-manager and nixos
    alias hms="home-manager switch --flake . || nix run .#homeConfigurations.(whoami).activationPackage"

    # cli tools and Utilities
    alias h="herdr"
    alias cmatrix="cmatrix -C blue"
    alias glow="glow -t"

    # Wayland Compositor (silent launch from TTY)
    alias n="niri >/dev/null 2>&1"

end
