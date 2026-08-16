# =============================================================================
#  AMD GPU Drivers, Hardware Acceleration & Display Flicker Fix
# =============================================================================
{
  config,
  lib,
  pkgs,
  gpuDriver ? "generic",
  ...
}: let
  isAmd = gpuDriver == "amd";
in {
  # ---------------------------------------------------------------------------
  # 🚀 Early Kernel Mode Setting (KMS) for AMD GPU
  # ---------------------------------------------------------------------------
  boot.initrd.kernelModules = lib.mkIf isAmd ["amdgpu"];

  # ---------------------------------------------------------------------------
  # ⚡ Display Flicker & Green Flash Fixes (PSR, SubVP, Scatter-Gather, ABM)
  # ---------------------------------------------------------------------------
  boot.kernelParams = lib.mkIf isAmd [
    "amdgpu.sg_display=0" # Fix green frame drops by forcing contiguous VRAM buffer on APUs
    "amdgpu.dcdebugmask=0x410" # Disable PSR (0x10) + SubVP memory clock transition hitching (0x400)
    "amdgpu.abmlevel=0" # Disable adaptive backlight contrast shifts to prevent panel flicker
  ];

  # ---------------------------------------------------------------------------
  # 🖥️ Video Drivers
  # ---------------------------------------------------------------------------
  services.xserver.videoDrivers = lib.mkIf isAmd ["amdgpu"];

  # ---------------------------------------------------------------------------
  # 🎮 Hardware Graphics Acceleration & 32-bit Support (Steam/Wine)
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
