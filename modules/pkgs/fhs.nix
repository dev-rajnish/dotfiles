# =============================================================================
#  FHS Sandbox Build Essentials Module
#  Auto-generated from tokens/pkgs/fhs.toml via MiniJinja (bin/pkg-render)
# =============================================================================
{
  pkgs,
  env,
  ...
}: {
  home-manager.users.${env.username} = {
    home.packages = [
      (pkgs.buildFHSEnv {
        name = "fhs-env";
        targetPkgs = pkgs:
          with pkgs; [
            cmake
            gcc
            glibc.dev
            gnumake
            libxml2.dev
            openssl.dev
            pkg-config
            zlib.dev
          ];
        runScript = pkgs.writeScript "fhs-entry" ''
          if [ $# -eq 0 ]; then
            exec "''${SHELL:-bash}"
          else
            exec "$@"
          fi
        '';
      })
    ];
    home.sessionPath = ["$HOME/.local/bin"];
  };
}
