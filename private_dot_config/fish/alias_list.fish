alias add-alias 'echo -e "$argv[2]" >> ~/.config/fish/alias_list.fish'

alias fish_dir 'cd ~/.config/fish/'

alias tm 'tmux new -s pre 2>/dev/null ; tmux attach -t pre'

alias n 'neo . && gh-this-dir'

alias r ranger

alias xplr 'xplr --print-pwd-as-result'

alias f 'cd $(xplr --print-pwd-as-result)'

alias my "cd $HOME/my || mkdir -p $HOME/my/ && cd $HOME/my  "
alias mcd 'mkdir -p $1 && cd $1'
alias batc "bat --theme='Monokai Extended' --paging never --style=grid,header"
alias ok clear
alias ls "eza --icons -1 -a"
alias l "eza --icons -1 -a"
alias ll "eza -lah --icons"
alias rm "rm -i"
alias k "sudo kmonad ~/.config/kmonad/config.kbd"

