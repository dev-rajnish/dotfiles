
function set_color_scheme
    # Base interface colors
    set -g fish_color_normal e2e2e2
    set -g fish_color_command f0c048
    set -g fish_color_keyword d7c5a0
    set -g fish_color_quote afcfab
    set -g fish_color_redirection e2e2e2
    set -g fish_color_end d7c5a0
    set -g fish_color_error ff0000
    set -g fish_color_param c6c6c6
    set -g fish_color_comment 919191
    set -g fish_color_selection 3f2e00 --bold --background=f0c048
    set -g fish_color_search_match 3f2e00 --bold --background=f0c048
    set -g fish_color_history_current --bold
    set -g fish_color_operator d7c5a0
    set -g fish_color_escape f0c048
    set -g fish_color_cwd f0c048
    set -g fish_color_cwd_root ffb4ab
    set -g fish_color_option d7c5a0
    set -g fish_color_valid_path f0c048 --underline=single
    set -g fish_color_autosuggestion 919191
    set -g fish_color_user d7c5a0
    set -g fish_color_host e2e2e2
    set -g fish_color_host_remote afcfab
    set -g fish_color_status ffb4ab
    set -g fish_color_cancel ff0000 --reverse

    # Pager & completions
    set -g fish_pager_color_background 131313
    set -g fish_pager_color_prefix f0c048 --bold --underline=single
    set -g fish_pager_color_progress 3f2e00 --bold --background=f0c048
    set -g fish_pager_color_completion e2e2e2
    set -g fish_pager_color_description d7c5a0
    set -g fish_pager_color_selected_background --background=f0c048
end
