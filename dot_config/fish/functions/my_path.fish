function my_path
    for p in "$HOME/.nix-profile/bin" "$HOME/.local/state/nix/profile/bin" "/etc/profiles/per-user/$USER/bin" "$HOME/.local/bin/fhs-env" "$HOME/.local/bin"
        if test -d "$p"; and not contains "$p" $PATH
            set -gx PATH "$p" $PATH
        end
    end
end
