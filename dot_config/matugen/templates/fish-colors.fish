
function set_color_scheme
    # Base interface colors
    set -g fish_color_normal {{colors.on_surface.default.hex}}
    set -g fish_color_command {{colors.primary.default.hex}}
    set -g fish_color_keyword {{colors.secondary.default.hex}}
    set -g fish_color_quote {{colors.tertiary.default.hex}}
    set -g fish_color_redirection {{colors.on_surface.default.hex}}
    set -g fish_color_end {{colors.secondary.default.hex}}
    set -g fish_color_error {{colors.red_value.default.hex}}
    set -g fish_color_param {{colors.on_surface_variant.default.hex}}
    set -g fish_color_comment {{colors.outline.default.hex}}
    set -g fish_color_selection {{colors.on_primary.default.hex}} --bold --background={{colors.primary.default.hex}}
    set -g fish_color_search_match {{colors.on_primary.default.hex}} --bold --background={{colors.primary.default.hex}}
    set -g fish_color_history_current --bold
    set -g fish_color_operator {{colors.secondary.default.hex}}
    set -g fish_color_escape {{colors.primary.default.hex}}
    set -g fish_color_cwd {{colors.primary.default.hex}}
    set -g fish_color_cwd_root {{colors.error.default.hex}}
    set -g fish_color_option {{colors.secondary.default.hex}}
    set -g fish_color_valid_path {{colors.primary.default.hex}} --underline=single
    set -g fish_color_autosuggestion {{colors.outline.default.hex}}
    set -g fish_color_user {{colors.secondary.default.hex}}
    set -g fish_color_host {{colors.on_surface.default.hex}}
    set -g fish_color_host_remote {{colors.tertiary.default.hex}}
    set -g fish_color_status {{colors.error.default.hex}}
    set -g fish_color_cancel {{colors.red_value.default.hex}} --reverse

    # Pager & completions
    set -g fish_pager_color_background {{colors.surface.default.hex}}
    set -g fish_pager_color_prefix {{colors.primary.default.hex}} --bold --underline=single
    set -g fish_pager_color_progress {{colors.on_primary.default.hex}} --bold --background={{colors.primary.default.hex}}
    set -g fish_pager_color_completion {{colors.on_surface.default.hex}}
    set -g fish_pager_color_description {{colors.secondary.default.hex}}
    set -g fish_pager_color_selected_background --background={{colors.primary.default.hex}}
end
