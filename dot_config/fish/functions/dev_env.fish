function dev_env --on-variable PWD
    # Distrobox / container no run
    if set -q CONTAINER_ID; or test -f /run/.containerenv
        echo "Inside Container"
        return
    end

    # ~/ws/code or child dir
    if string match -q "$HOME/ws/code" "$PWD"; or string match -q "$HOME/ws/code/*" "$PWD"; or test -f ".dev"
        echo "Entering Development Environment..."
         $HOME/ws/code/.dev.sh
    end
end
