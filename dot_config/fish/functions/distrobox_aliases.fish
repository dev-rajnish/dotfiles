# =============================================================================
#  Distrobox Auto-Alias & Function Generator
# =============================================================================

function distrobox_aliases --description "Dynamically creates functions for all Distrobox containers"
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
