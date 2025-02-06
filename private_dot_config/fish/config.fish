if status is-interactive
    #------------------------
    executables
    init_fish
    ls_color
    utheme
    #+======================
    source ~/.config/fish/source_file.fish



    #--------------------------
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
