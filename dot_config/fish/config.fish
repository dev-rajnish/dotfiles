if status is-interactive
  my_alias
  my_var
  my_path
  set_color_scheme
  dev_env

  if type -q starship
  starship init fish | source
  end

end


# Added by Antigravity CLI installer
set -gx PATH "/home/rsh/.local/bin" $PATH
