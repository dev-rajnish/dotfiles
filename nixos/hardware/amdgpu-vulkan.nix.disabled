{pkgs, ...}: {
  # Enable AMD GPU kernel drivers early in boot
  boot.initrd.kernelModules = ["amdgpu"];

  services.xserver.videoDrivers = ["amdgpu"];

  # Enable Hardware Graphics (Mesa OpenGL, Vulkan & VA-API Video Acceleration)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
      rocmPackages.clr.icd
    ];
  };

  # System-wide Environment variables for Hardware Acceleration (GPU, VA-API, Wayland/Ozone, AI)
  environment = {
    sessionVariables = {
      # System-wide VA-API Hardware Video Acceleration for AMD
      LIBVA_DRIVER_NAME = "mesa";
      VDPAU_DRIVER = "va_gl";

      # Force Wayland & GPU Hardware Acceleration for Chromium/Electron/Firefox apps
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";

      # AI / ROCm / Vulkan on AMD Radeon RX 6500M (Navi 24 - gfx1034)
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
      ROC_ENABLE_PREEMPTION_MODE = "1";
    };

    # System packages for GPU, VA-API diagnostic & Vulkan AI tools
    systemPackages = with pkgs; [
      clinfo
      libva-utils
      pciutils
      rocmPackages.rocm-smi
      vulkan-tools
    ];
  };
}
