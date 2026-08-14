# =============================================================================
#  Sandboxed FHS Environment & Wrapper Script Generator
# =============================================================================
{
  pkgs,
  lib,
  pkgList,
  ...
}: let
  # Packages installed inside FHS sandbox (Rust toolchain, build essentials)
  fhsPackages = (pkgList pkgs).fhs;

  # ---------------------------------------------------------------------------
  # 1. 📦 FHS Environment Sandbox Definition
  # ---------------------------------------------------------------------------
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

  # ---------------------------------------------------------------------------
  # 2. ⚡ Wrapper Generator for FHS Binaries and Desktop Entries
  # ---------------------------------------------------------------------------
  fhsWrappers = pkgs.runCommand "fhs-env-wrappers" {} ''
        mkdir -p $out/bin $out/libexec/fhs-env $out/share/applications

        for pkg in ${lib.concatStringsSep " " (map (p: "${p}") fhsPackages)}; do
          # Create binary wrappers
          if [ -d "$pkg/bin" ]; then
            for bin in "$pkg/bin"/*; do
              if [ -x "$bin" ]; then
                binName=$(basename "$bin")

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

          # Rewrite desktop application entries to launch inside FHS
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
  # ---------------------------------------------------------------------------
  # 3. 🚀 User Package and PATH Integration
  # ---------------------------------------------------------------------------
  home.packages = [
    myAppEnv
    fhsWrappers
  ];

  # Add FHS wrappers to user PATH
  home.sessionPath = [
    "$HOME/.local/bin/fhs-env"
    "$HOME/.local/bin"
  ];

  # Link FHS binary wrapper directory
  home.file.".local/bin/fhs-env".source = "${fhsWrappers}/libexec/fhs-env";
}
