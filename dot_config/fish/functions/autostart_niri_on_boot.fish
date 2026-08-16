function autostart_niri_on_boot --description "Auto-start Niri session strictly once per system boot on TTY1"
    if status is-login
        if test (tty) = /dev/tty1
            and test -z "$WAYLAND_DISPLAY"
            and test -z "$DISPLAY"
            set -l flag "/run/user/"(id -u)"/.niri_boot_done"
            if not test -f "$flag"
                touch "$flag"
                niri-session
            end
        end
    end
end
