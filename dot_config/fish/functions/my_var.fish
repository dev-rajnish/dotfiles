function my_var
    set -Ux FISH_VAR "set from function"
    set -Ux FASTBOOT "fastboot -S 32K"

    # Pfetch Minimalist Customization (Custom Anime ASCII & Tokyo Night Theme)
    set -gx PF_INFO "ascii title os host kernel uptime pkgs memory wm shell palette"
    set -gx PF_CUSTOM_ASCII "$HOME/.config/pfetch/ascii.txt"
    set -gx PF_COL1 4
    set -gx PF_COL2 6
    set -gx PF_COL3 5
    set -gx PF_SEP " 󰄾 "
end
