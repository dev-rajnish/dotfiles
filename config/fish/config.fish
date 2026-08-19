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
end

# Initialize Direnv Hook
if type -q direnv
    direnv hook fish | source
end
