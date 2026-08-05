function modern_utils
 # 1. Eza setup
if type -q eza
    alias ls="eza --icons --group-directories-first"
    alias ll="eza -l --icons --git --group-directories-first"
    alias la="eza -la --icons --git --group-directories-first"
    alias lt="eza --tree --icons --level=2"
end

# 2. Bat setup
if type -q bat
    alias cat="bat --style=header,grid"
    set -gx BAT_THEME "ansi"
end

# 3. Fd setup (find replacement)
if type -q fd
    alias find="fd"
end

# 4. Ripgrep setup (grep replacement)
if type -q rg
    alias grep="rg"
end

# 5. Procs setup (ps replacement)
if type -q procs
    alias ps="procs"
end

# 6. Bottom setup (top replacement)
if type -q btm
    alias top="btm"
end

# 7. Zoxide setup
if type -q zoxide
    zoxide init fish | source
end
end
