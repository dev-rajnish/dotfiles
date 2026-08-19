# =============================================================================
#  Fish Command Not Found Handler using Comma (,) & Nix-Index
# =============================================================================

function fish_command_not_found
    set -l cmd $argv[1]

    # If comma (,) is available, execute with comma on the fly
    if type -q ,
        echo -e "\e[1;33mCommand '$cmd' not found.\e[0m Running on-the-fly with \e[1;36mcomma (,)\e[0m...\n"
        , $argv
        return $status
    else if type -q nix-locate
        echo -e "\e[1;33mCommand '$cmd' not found.\e[0m Searching in nixpkgs...\n"
        nix-locate --top-level --minimal --at-root --whole-name "bin/$cmd"
        return 127
    else
        __fish_default_command_not_found_handler $argv
        return 127
    end
end
