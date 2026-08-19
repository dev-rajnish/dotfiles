# =============================================================================
#  ⚡ Nushell Interactive Session Configuration (config.nu)
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Shell Behavior, Tables & Completion Engine
# -----------------------------------------------------------------------------
$env.config = {
    show_banner: false
    table: {
        mode: rounded
        index_mode: always
        show_empty: true
        padding: { left: 1, right: 1 }
        trim: {
            methodology: "wrapping"
            wrapping_try_keep_words: true
        }
    }
    history: {
        max_size: 100000
        sync_on_enter: true
        file_format: "plaintext"
        isolation: false
    }
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy"
        external: {
            enable: true
            max_results: 100
        }
    }
    edit_mode: "emacs"
    cursor_shape: {
        emacs: "line"
        vi_insert: "line"
        vi_normal: "block"
    }
    use_kitty_protocol: true
}

# -----------------------------------------------------------------------------
# 2. Modern CLI Tool Aliases (Eza, Bat, Ripgrep, etc.)
# -----------------------------------------------------------------------------
alias ls = eza --icons --group-directories-first
alias ll = eza -l --icons --git --group-directories-first
alias la = eza -la --icons --git --group-directories-first
alias lt = eza --tree --icons --level=2

alias cat = bat --style=header,grid
alias find = fd
alias grep = rg
alias ps = procs
alias top = btm
alias c = clear
alias q = exit

# -----------------------------------------------------------------------------
# 3. Yazi File Manager with Working Directory Sync (y)
# -----------------------------------------------------------------------------
def --env y [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX")
    ^yazi ...$args --cwd-file $tmp
    if ($tmp | path exists) {
        let cwd = (open $tmp | str trim)
        if $cwd != "" and $cwd != $env.PWD {
            cd $cwd
        }
        rm -fp $tmp
    }
}

# -----------------------------------------------------------------------------
# 4. Dotfiles & System Navigation Aliases
# -----------------------------------------------------------------------------
alias .nu = cd ~/.config/nushell/
alias .l = cd ~/.local/
alias .b = cd ~/.local/bin/
alias .s = cd ~/.local/share/
alias .sl = cd ~/shoelace
alias .d = cd ~/shoelace
alias .appearance = xdg-open ~/.config/0-apperance/appearance.toml
alias .c = cd ~/.config/
alias .h = cd ~/_ws/dotfiles/home-manager/
alias .w = cd ~/_ws/walls/

alias d = dot
alias cmatrix = cmatrix -C blue
alias glow = glow -t

# -----------------------------------------------------------------------------
# 5. Tool Integrations (Starship, Zoxide, Atuin)
# -----------------------------------------------------------------------------
# Zoxide Directory Jumper (z and zi)
source ~/.config/nushell/zoxide.nu

# Atuin Shell History Search (Ctrl+R / Up arrow)
source ~/.config/nushell/atuin.nu

# Starship Cross-Shell Prompt
use ~/.config/nushell/starship.nu

# -----------------------------------------------------------------------------
# 6. Shoelace Dynamic Aliases
# -----------------------------------------------------------------------------
source ~/.config/nushell/sl_alias.nu


