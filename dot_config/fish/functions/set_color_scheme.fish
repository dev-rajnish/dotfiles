
function set_color_scheme
    # Base interface colors
    set -g fish_color_normal d8e5e9
    set -g fish_color_command 00d9f9
    set -g fish_color_keyword a7cce1
    set -g fish_color_quote a3caf4
    set -g fish_color_redirection d8e5e9
    set -g fish_color_end a7cce1
    set -g fish_color_error ff0000
    set -g fish_color_param bcc9cc
    set -g fish_color_comment 869396
    set -g fish_color_selection 00363f --bold --background=00d9f9
    set -g fish_color_search_match 00363f --bold --background=00d9f9
    set -g fish_color_history_current --bold
    set -g fish_color_operator a7cce1
    set -g fish_color_escape 00d9f9
    set -g fish_color_cwd 00d9f9
    set -g fish_color_cwd_root ffb4ab
    set -g fish_color_option a7cce1
    set -g fish_color_valid_path 00d9f9 --underline=single
    set -g fish_color_autosuggestion 869396
    set -g fish_color_user a7cce1
    set -g fish_color_host d8e5e9
    set -g fish_color_host_remote a3caf4
    set -g fish_color_status ffb4ab
    set -g fish_color_cancel ff0000 --reverse

    # Pager & completions
    set -g fish_pager_color_background 091518
    set -g fish_pager_color_prefix 00d9f9 --bold --underline=single
    set -g fish_pager_color_progress 00363f --bold --background=00d9f9
    set -g fish_pager_color_completion d8e5e9
    set -g fish_pager_color_description a7cce1
    set -g fish_pager_color_selected_background --background=00d9f9
end
