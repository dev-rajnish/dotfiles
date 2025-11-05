
function set_color_scheme
    # Base interface colors
    set -g fish_color_normal f7dce0
    set -g fish_color_command ffb1c1
    set -g fish_color_keyword f5b7b1
    set -g fish_color_quote ffb598
    set -g fish_color_redirection f7dce0
    set -g fish_color_end f5b7b1
    set -g fish_color_error ff0000
    set -g fish_color_param dac0c4
    set -g fish_color_comment a28b8e
    set -g fish_color_selection 660029 --bold --background=ffb1c1
    set -g fish_color_search_match 660029 --bold --background=ffb1c1
    set -g fish_color_history_current --bold
    set -g fish_color_operator f5b7b1
    set -g fish_color_escape ffb1c1
    set -g fish_color_cwd ffb1c1
    set -g fish_color_cwd_root ffb4ab
    set -g fish_color_option f5b7b1
    set -g fish_color_valid_path ffb1c1 --underline=single
    set -g fish_color_autosuggestion a28b8e
    set -g fish_color_user f5b7b1
    set -g fish_color_host f7dce0
    set -g fish_color_host_remote ffb598
    set -g fish_color_status ffb4ab
    set -g fish_color_cancel ff0000 --reverse

    # Pager & completions
    set -g fish_pager_color_background 1d1012
    set -g fish_pager_color_prefix ffb1c1 --bold --underline=single
    set -g fish_pager_color_progress 660029 --bold --background=ffb1c1
    set -g fish_pager_color_completion f7dce0
    set -g fish_pager_color_description f5b7b1
    set -g fish_pager_color_selected_background --background=ffb1c1
end
