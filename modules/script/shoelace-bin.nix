{
  config,
  pkgs,
  lib,
  env,
  ...
}: let
  cfg = config.mySystem.script.shoelace-bin;
  shoelaceBin = pkgs.runCommandLocal "shoelace-bin" {} ''
    mkdir -p $out/bin
    cp -a ${../../bin}/* $out/bin/
    chmod +x $out/bin/*
  '';
in {
  options.mySystem.script.shoelace-bin = {
    enable = lib.mkEnableOption "shoelace bin scripts package";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${env.username} = {
      home.packages = [
        shoelaceBin
      ];
    };
  };
}
