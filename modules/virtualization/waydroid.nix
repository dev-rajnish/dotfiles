{
  config,
  pkgs,
  lib,
  env,
  ...
}: let
  cfg = config.mySystem.virtualization.waydroid;
in {
  options.mySystem.virtualization.waydroid = {
    enable = lib.mkEnableOption "waydroid config";
  };

  config = lib.mkIf cfg.enable {
    # ---------------------------------------------------------------------------
    # 🤖 Waydroid Android Container
    # ---------------------------------------------------------------------------
    virtualisation.waydroid = {
      enable = env.enableWaydroid or false;
      package =
        if config.networking.nftables.enable
        then pkgs.waydroid-nftables
        else pkgs.waydroid;
    };

    # Safe conditional environment override (avoids bad unit file errors when disabled)
    systemd.services.waydroid-container.environment.LXC_USE_NFT = lib.mkIf (env.enableWaydroid or false) "true";
  };
}
