
function set_color_scheme
    # Base interface colors
    set -g fish_color_normal d9e4eb
    set -g fish_color_command 69d3ff
    set -g fish_color_keyword aec9e6
    set -g fish_color_quote afc7f8
    set -g fish_color_redirection d9e4eb
    set -g fish_color_end aec9e6
    set -g fish_color_error ff0000
    set -g fish_color_param bdc8cf
    set -g fish_color_comment 879299
    set -g fish_color_selection 003546 --bold --background=69d3ff
    set -g fish_color_search_match 003546 --bold --background=69d3ff
    set -g fish_color_history_current --bold
    set -g fish_color_operator aec9e6
    set -g fish_color_escape 69d3ff
    set -g fish_color_cwd 69d3ff
    set -g fish_color_cwd_root ffb4ab
    set -g fish_color_option aec9e6
    set -g fish_color_valid_path 69d3ff --underline=single
    set -g fish_color_autosuggestion 879299
    set -g fish_color_user aec9e6
    set -g fish_color_host d9e4eb
    set -g fish_color_host_remote afc7f8
    set -g fish_color_status ffb4ab
    set -g fish_color_cancel ff0000 --reverse

    # Pager & completions
    set -g fish_pager_color_background 0a151a
    set -g fish_pager_color_prefix 69d3ff --bold --underline=single
    set -g fish_pager_color_progress 003546 --bold --background=69d3ff
    set -g fish_pager_color_completion d9e4eb
    set -g fish_pager_color_description aec9e6
    set -g fish_pager_color_selected_background --background=69d3ff
end
