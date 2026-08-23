# =============================================================================
#  Fish Shell Main Configuration (config.fish)
# =============================================================================

# Disable default startup greeting
set -g fish_greeting ""

# Initialize Starship Prompt
if type -q starship
    starship init fish | source
end

# Initialize Zoxide (Smart cd)
if type -q zoxide
    zoxide init fish | source
    abbr --add cd z
    abbr --add g zi
end

# Initialize Direnv Hook
if type -q direnv
    direnv hook fish | source
end

# Enable Vi Key Bindings (Vim mode in terminal)
fish_vi_key_bindings
set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_replace_one underscore
set -g fish_cursor_visual block
