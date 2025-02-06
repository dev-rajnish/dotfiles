function init_fish

    #starship
    starship init fish | source

    #zoxide
    set -gx _ZO_ECHO 1
    zoxide init --cmd=cd --hook=prompt fish | source

end
