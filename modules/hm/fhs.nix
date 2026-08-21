{ env,  config,  lib, 
  pkgs,
  pkgList,
  ...
}:
let
  cfg = config.mySystem.hm.fhs;
in {
  options.mySystem.hm.fhs = {
    enable = lib.mkEnableOption "fhs config";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = { config, ... }: (
    let
  # Packages installed inside FHS sandbox (C build essentials, headers, rustup)
  fhsPackages = (pkgList pkgs).fhs;

  # ---------------------------------------------------------------------------
  # 📦 FHS Environment Sandbox Definition
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
in {
  # ---------------------------------------------------------------------------
  # 🚀 FHS Sandbox Binary & User PATH
  # ---------------------------------------------------------------------------
  home.packages = [
    myAppEnv
  ];

  # Standard user binary directory
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
  );
  };
}
