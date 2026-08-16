# =============================================================================
#  Dynamic Theming: Fish Shell Base16 Palette
# =============================================================================
{
  pkgs,
  tokens,
}: let
  inherit (tokens) rawColors;

  fishColors = pkgs.writeText "colors.fish" ''
    function colors
        # Auto-generated Base16 Color Scheme for Fish Shell - Do not edit manually
        set -g fish_color_normal ${rawColors.base05}
        set -g fish_color_command ${rawColors.base0D}
        set -g fish_color_keyword ${rawColors.base0E}
        set -g fish_color_quote ${rawColors.base0B}
        set -g fish_color_redirection ${rawColors.base0C}
        set -g fish_color_end ${rawColors.base09}
        set -g fish_color_error ${rawColors.base08}
        set -g fish_color_param ${rawColors.base0E}
        set -g fish_color_comment ${rawColors.base03}
        set -g fish_color_selection --background=${rawColors.base02}
        set -g fish_color_search_match --background=${rawColors.base02}
        set -g fish_color_operator ${rawColors.base0B}
        set -g fish_color_escape ${rawColors.base0E}
        set -g fish_color_autosuggestion ${rawColors.base03}
        set -g fish_color_cancel ${rawColors.base08} --reverse
        set -g fish_color_cwd ${rawColors.base0D}
        set -g fish_color_cwd_root ${rawColors.base08}
        set -g fish_color_user ${rawColors.base0C}
        set -g fish_color_host ${rawColors.base0E}
        set -g fish_color_host_remote ${rawColors.base0E}
        set -g fish_color_status ${rawColors.base08}
        set -g fish_color_option ${rawColors.base0C}
        set -g fish_color_valid_path ${rawColors.base0C} --underline

        # Pager & Completion Menu Colors
        set -g fish_pager_color_progress ${rawColors.base03}
        set -g fish_pager_color_prefix ${rawColors.base0C} --bold
        set -g fish_pager_color_completion ${rawColors.base05}
        set -g fish_pager_color_description ${rawColors.base03}
        set -g fish_pager_color_selected_background --background=${rawColors.base02}
        set -g fish_pager_color_selected_prefix ${rawColors.base0C}
        set -g fish_pager_color_selected_completion ${rawColors.base05}
        set -g fish_pager_color_selected_description ${rawColors.base0D}
        set -g fish_pager_color_secondary_background ${rawColors.base00}
    end
  '';
in {
  inherit fishColors;
}
