# =============================================================================
#  Fish Command Not Found Handler using Comma (,) & Nix-Index
# =============================================================================

function fish_command_not_found
    set -l cmd $argv[1]

    # ---------------------------------------------------------------------------
    # 📦 Distrobox container fallback: forward missing commands to host-spawn
    # ---------------------------------------------------------------------------
    if test -f /run/.containerenv; or test -n "$CONTAINER_ID"; or test -n "$DISTROBOX_ENTERED"
        if type -q host-spawn
            echo -e "\e[1;33mCommand '$cmd' not found in container.\e[0m Executing on host with \e[1;36mhost-spawn\e[0m...\n"
            host-spawn $argv
            return $status
        else if type -q distrobox-host-exec
            echo -e "\e[1;33mCommand '$cmd' not found in container.\e[0m Executing on host with \e[1;36mdistrobox-host-exec\e[0m...\n"
            env DISTROBOX_HOST_EXEC_ENGINE=host-spawn distrobox-host-exec $argv
            return $status
        end
    end

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
