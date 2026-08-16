# =============================================================================
#  Waydroid Android Container Subsystem
# =============================================================================
{
  config,
  pkgs,
  lib,
  enableWaydroid ? false,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🤖 Waydroid Android Container
  # ---------------------------------------------------------------------------
  virtualisation.waydroid = {
    enable = enableWaydroid;
    package =
      if config.networking.nftables.enable
      then pkgs.waydroid-nftables
      else pkgs.waydroid;
  };

  # Safe conditional environment override (avoids bad unit file errors when disabled)
  systemd.services.waydroid-container.environment.LXC_USE_NFT = lib.mkIf enableWaydroid "true";
}
