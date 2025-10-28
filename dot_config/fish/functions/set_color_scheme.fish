
function set_color_scheme
    # Base interface colors
    set -g fish_color_normal e2e2e2
    set -g fish_color_command 4cd9e0
    set -g fish_color_keyword b1cccd
    set -g fish_color_quote b5c7e9
    set -g fish_color_redirection e2e2e2
    set -g fish_color_end b1cccd
    set -g fish_color_error ff0000
    set -g fish_color_param c6c6c6
    set -g fish_color_comment 919191
    set -g fish_color_selection 003739 --bold --background=4cd9e0
    set -g fish_color_search_match 003739 --bold --background=4cd9e0
    set -g fish_color_history_current --bold
    set -g fish_color_operator b1cccd
    set -g fish_color_escape 4cd9e0
    set -g fish_color_cwd 4cd9e0
    set -g fish_color_cwd_root ffb4ab
    set -g fish_color_option b1cccd
    set -g fish_color_valid_path 4cd9e0 --underline=single
    set -g fish_color_autosuggestion 919191
    set -g fish_color_user b1cccd
    set -g fish_color_host e2e2e2
    set -g fish_color_host_remote b5c7e9
    set -g fish_color_status ffb4ab
    set -g fish_color_cancel ff0000 --reverse

    # Pager & completions
    set -g fish_pager_color_background 131313
    set -g fish_pager_color_prefix 4cd9e0 --bold --underline=single
    set -g fish_pager_color_progress 003739 --bold --background=4cd9e0
    set -g fish_pager_color_completion e2e2e2
    set -g fish_pager_color_description b1cccd
    set -g fish_pager_color_selected_background --background=4cd9e0
end
