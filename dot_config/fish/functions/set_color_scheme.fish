
function set_color_scheme
    # Base interface colors
    set -g fish_color_normal e2e1ef
    set -g fish_color_command bcc2ff
    set -g fish_color_keyword cbc1e9
    set -g fish_color_quote d9bbf2
    set -g fish_color_redirection e2e1ef
    set -g fish_color_end cbc1e9
    set -g fish_color_error ff0000
    set -g fish_color_param c6c5d3
    set -g fish_color_comment 908f9c
    set -g fish_color_selection 00169d --bold --background=bcc2ff
    set -g fish_color_search_match 00169d --bold --background=bcc2ff
    set -g fish_color_history_current --bold
    set -g fish_color_operator cbc1e9
    set -g fish_color_escape bcc2ff
    set -g fish_color_cwd bcc2ff
    set -g fish_color_cwd_root ffb4ab
    set -g fish_color_option cbc1e9
    set -g fish_color_valid_path bcc2ff --underline=single
    set -g fish_color_autosuggestion 908f9c
    set -g fish_color_user cbc1e9
    set -g fish_color_host e2e1ef
    set -g fish_color_host_remote d9bbf2
    set -g fish_color_status ffb4ab
    set -g fish_color_cancel ff0000 --reverse

    # Pager & completions
    set -g fish_pager_color_background 12131c
    set -g fish_pager_color_prefix bcc2ff --bold --underline=single
    set -g fish_pager_color_progress 00169d --bold --background=bcc2ff
    set -g fish_pager_color_completion e2e1ef
    set -g fish_pager_color_description cbc1e9
    set -g fish_pager_color_selected_background --background=bcc2ff
end
