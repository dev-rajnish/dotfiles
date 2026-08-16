# =============================================================================
#  Fish Command Not Found Handler -> Distrobox Host Forwarding
# =============================================================================

function fish_command_not_found --description "Transparently fallback to distrobox-host-exec if inside a container"
    # Check if running inside a container (Distrobox / Podman / Docker)
    if test -e /run/.containerenv -o -e /.dockerenv
        if type -q distrobox-host-exec
            distrobox-host-exec $argv
            return $status
        end
    end

    # Fallback to default fish error handler when on host or if host-exec is unavailable
    __fish_default_command_not_found_handler $argv
end
