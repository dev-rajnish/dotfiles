
function set_color_scheme
    # Base interface colors
    set -g fish_color_normal e2e2e2
    set -g fish_color_command ffb870
    set -g fish_color_keyword e1c1a4
    set -g fish_color_quote c0cc9a
    set -g fish_color_redirection e2e2e2
    set -g fish_color_end e1c1a4
    set -g fish_color_error ff0000
    set -g fish_color_param c6c6c6
    set -g fish_color_comment 919191
    set -g fish_color_selection 4a2800 --bold --background=ffb870
    set -g fish_color_search_match 4a2800 --bold --background=ffb870
    set -g fish_color_history_current --bold
    set -g fish_color_operator e1c1a4
    set -g fish_color_escape ffb870
    set -g fish_color_cwd ffb870
    set -g fish_color_cwd_root ffb4ab
    set -g fish_color_option e1c1a4
    set -g fish_color_valid_path ffb870 --underline=single
    set -g fish_color_autosuggestion 919191
    set -g fish_color_user e1c1a4
    set -g fish_color_host e2e2e2
    set -g fish_color_host_remote c0cc9a
    set -g fish_color_status ffb4ab
    set -g fish_color_cancel ff0000 --reverse

    # Pager & completions
    set -g fish_pager_color_background 131313
    set -g fish_pager_color_prefix ffb870 --bold --underline=single
    set -g fish_pager_color_progress 4a2800 --bold --background=ffb870
    set -g fish_pager_color_completion e2e2e2
    set -g fish_pager_color_description e1c1a4
    set -g fish_pager_color_selected_background --background=ffb870
end
