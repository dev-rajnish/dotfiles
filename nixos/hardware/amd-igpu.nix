# =============================================================================
#  AMD GPU Drivers, Hardware Acceleration & Display Flicker Fix
# =============================================================================
{
  config,
  lib,
  pkgs,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 1. 🚀 Early Kernel Mode Setting (KMS) for AMD GPU
  # ---------------------------------------------------------------------------
  boot.initrd.kernelModules = ["amdgpu"];

  # ---------------------------------------------------------------------------
  # 2. ⚡ Disable Panel Self Refresh (PSR) on eDP to prevent screen flickering
  # ---------------------------------------------------------------------------
  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x10"
  ];

  # ---------------------------------------------------------------------------
  # 3. 🖥️ Video Drivers
  # ---------------------------------------------------------------------------
  services.xserver.videoDrivers = ["amdgpu"];

  # ---------------------------------------------------------------------------
  # 4. 🎮 Hardware Graphics Acceleration & 32-bit Support (Steam/Wine)
  # ---------------------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit graphics acceleration for Wine & Steam
    extraPackages = with pkgs; [
      libva
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
      libvdpau-va-gl
    ];
  };

  # Optional: Enable OpenCL / ROCm compute acceleration for AMD iGPU
  # hardware.graphics.extraPackages = with pkgs; [ rocmPackages.clr ];
}
