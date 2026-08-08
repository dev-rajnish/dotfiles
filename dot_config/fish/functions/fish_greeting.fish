function fish_greeting
    if type -q nerdfetch
        nerdfetch
        return
    else if type -q pfetch
        pfetch
        return
    else if type -q fastfetch
        fastfetch
        return
    end

end
