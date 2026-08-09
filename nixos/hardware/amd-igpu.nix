{
  config,
  lib,
  pkgs,
  ...
}: {
  # 1. Force early kernel mode setting for AMD GPU
  boot.initrd.kernelModules = ["amdgpu"];

  # 2. Specify AMD GPU video driver
  services.xserver.videoDrivers = ["amdgpu"];

  # 3. Enable Hardware Graphics Acceleration & 32-bit support (Steam/Wine)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Enables 32-bit graphics acceleration for Steam/Wine
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
