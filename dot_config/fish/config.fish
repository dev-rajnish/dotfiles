if status is-interactive
    modern_utils
    my_alias
    my_var
    my_path
    colors
    distrobox_aliases

    if test -f ~/.config/fish/functions/dev_env.fish
        dev_env
    end

    if type -q starship
        starship init fish | source
    end

    if type -q zoxide
        zoxide init fish | source
        alias cd="z"
    end

    if type -q exercism
        exercism completion fish | source
    end
    if type -q atuin
        atuin init fish | source
    end

    if type -q direnv
        direnv hook fish | source
    end
    if type -q just
        JUST_COMPLETE=fish just | source
    end
end

# -----------------------------------------------------------------------------
# 🚀 Auto-start Niri session on fresh boot
# -----------------------------------------------------------------------------
autostart_niri_on_boot

# Dynamically add dotfiles scripts to PATH
for scripts_dir in "$HOME/_ws/dotfiles/scripts" "$HOME/dotfiles/scripts" "$HOME/.dotfiles/scripts"
    if test -d "$scripts_dir"
        set -gx PATH "$scripts_dir" $PATH
        break
    end
end

# Standard user local binaries
if test -d "$HOME/.local/bin"
    set -gx PATH "$HOME/.local/bin" $PATH
end
