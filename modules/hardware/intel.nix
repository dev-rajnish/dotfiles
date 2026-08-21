{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.hardware.intel;
in {
  options.mySystem.hardware.intel = {
    enable = lib.mkEnableOption "Intel Hardware config";
  };

  config = lib.mkIf cfg.enable {
    # ---------------------------------------------------------------------------
    # 🚀 Early Kernel Mode Setting (KMS) for Intel GPU
    # ---------------------------------------------------------------------------
    boot.initrd.kernelModules = [ "i915" ];

    # ---------------------------------------------------------------------------
    # 🖥️ Video Drivers
    # ---------------------------------------------------------------------------
    services.xserver.videoDrivers = [ "modesetting" ];

    # ---------------------------------------------------------------------------
    # 🎮 Hardware Graphics Acceleration & 32-bit Support (Steam/Wine)
    # ---------------------------------------------------------------------------
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver
        libvdpau-va-gl
      ];
    };
  };
}
