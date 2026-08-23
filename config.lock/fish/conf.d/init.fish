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
