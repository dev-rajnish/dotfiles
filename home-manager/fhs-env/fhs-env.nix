{
  pkgs,
  lib,
  ...
}: let
  # Add packages to install inside FHS environment
  fhsPackages = with pkgs; [
    neovim
    fzf
    yazi
    tree-sitter
    luajit
    rustc
    rustup
    cargo
    rustlings
    rust-analyzer
    zed-editor
  ];

  myAppEnv = pkgs.buildFHSEnv {
    name = "fhs-env";

    targetPkgs = pkgs: fhsPackages;

    runScript = pkgs.writeScript "fhs-entry" ''
      if [ $# -eq 0 ]; then
        exec "''${SHELL:-bash}"
      else
        exec "$@"
      fi
    '';
  };

  # Build wrappers & modified .desktop files at build-time (pure derivation)
  fhsWrappers = pkgs.runCommand "fhs-env-wrappers" {} ''
        mkdir -p $out/bin $out/libexec/fhs-env $out/share/applications

        for pkg in ${lib.concatStringsSep " " (map (p: "${p}") fhsPackages)}; do
          # 1. Generate executable wrappers for all binaries in the package
          if [ -d "$pkg/bin" ]; then
            for bin in "$pkg/bin"/*; do
              if [ -x "$bin" ]; then
                binName=$(basename "$bin")

                # Create wrapper in both $out/bin and $out/libexec/fhs-env
                for targetDir in "$out/bin" "$out/libexec/fhs-env"; do
                  wrapper="$targetDir/$binName"
                  if [ ! -f "$wrapper" ]; then
                    cat <<EOF > "$wrapper"
    #!/bin/sh
    exec ${myAppEnv}/bin/fhs-env $binName "\$@"
    EOF
                    chmod +x "$wrapper"
                  fi
                done
              fi
            done
          fi

          # 2. Copy and rewrite .desktop files to launch inside FHS environment
          if [ -d "$pkg/share/applications" ]; then
            for desktop in "$pkg/share/applications"/*.desktop; do
              if [ -f "$desktop" ]; then
                desktopName=$(basename "$desktop")
                if [ ! -f "$out/share/applications/$desktopName" ]; then
                  sed -e 's|^Exec=\(.*\)|Exec='${myAppEnv}'/bin/fhs-env \1|g' \
                      -e 's|^TryExec=.*|# TryExec=|g' \
                      "$desktop" > "$out/share/applications/$desktopName"
                fi
              fi
            done
          fi
        done
  '';
in {
  home.packages = [
    myAppEnv
    fhsWrappers
  ];

  # Set PATH environment variables directly in Home-Manager Nix config
  home.sessionPath = [
    "$HOME/.local/bin/fhs-env"
    "$HOME/.local/bin"
  ];

  # Symlink ~/.local/bin/fhs-env to point to the build-time wrappers directory
  home.file.".local/bin/fhs-env".source = "${fhsWrappers}/libexec/fhs-env";
}
