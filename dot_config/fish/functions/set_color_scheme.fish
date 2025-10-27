
function set_color_scheme
    # Base interface colors
    set -g fish_color_normal e2e2e2
    set -g fish_color_command a1d57a
    set -g fish_color_keyword becbaf
    set -g fish_color_quote a0cfce
    set -g fish_color_redirection e2e2e2
    set -g fish_color_end becbaf
    set -g fish_color_error ff0000
    set -g fish_color_param c6c6c6
    set -g fish_color_comment 919191
    set -g fish_color_selection 173800 --bold --background=a1d57a
    set -g fish_color_search_match 173800 --bold --background=a1d57a
    set -g fish_color_history_current --bold
    set -g fish_color_operator becbaf
    set -g fish_color_escape a1d57a
    set -g fish_color_cwd a1d57a
    set -g fish_color_cwd_root ffb4ab
    set -g fish_color_option becbaf
    set -g fish_color_valid_path a1d57a --underline=single
    set -g fish_color_autosuggestion 919191
    set -g fish_color_user becbaf
    set -g fish_color_host e2e2e2
    set -g fish_color_host_remote a0cfce
    set -g fish_color_status ffb4ab
    set -g fish_color_cancel ff0000 --reverse

    # Pager & completions
    set -g fish_pager_color_background 131313
    set -g fish_pager_color_prefix a1d57a --bold --underline=single
    set -g fish_pager_color_progress 173800 --bold --background=a1d57a
    set -g fish_pager_color_completion e2e2e2
    set -g fish_pager_color_description becbaf
    set -g fish_pager_color_selected_background --background=a1d57a
end
