if status is-interactive
  modern_utils
  my_alias
  my_var
  my_path
  set_color_scheme

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

end


# Added by Antigravity CLI installer
set -gx PATH "/home/rsh/.local/bin" $PATH
