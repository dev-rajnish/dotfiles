# =============================================================================
#  Distrobox Auto-Alias & Function Generator
# =============================================================================

function distrobox_aliases --description "Dynamically creates functions for Distrobox containers & host execution"
    if test -e /run/.containerenv -o -e /.dockerenv
        # Inside container: create a convenient 'host' helper function
        function host --description "Execute command on the host system"
            if type -q distrobox-host-exec
                distrobox-host-exec $argv
            else
                $argv
            end
        end
    else
        # On host: dynamically create functions for each distrobox container
        if type -q podman; and type -q distrobox
            for box in (podman ps -a --format "{{.Names}}" 2>/dev/null)
                # Only create function if container name doesn't clash with an existing binary/built-in
                if not type -q $box
                    eval "function $box --description \"Enter distrobox container: $box\"
                        if test (count \$argv) -gt 0
                            distrobox enter $box -- \$argv
                        else
                            distrobox enter $box
                        end
                    end"
                end
            end
        end
    end
end
