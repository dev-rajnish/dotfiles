# =============================================================================
#  AMD Host Configuration (modules/hosts/amd.nix)
#  Primary machine profile for AMD CPU + AMD GPU (Active Laptop)
# =============================================================================
{
  config,
  lib,
  pkgs,
  modulesPath,
  env,
  ...
}: {
  imports = [
    ./common.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ---------------------------------------------------------------------------
  # ⚡ CPU & Kernel Modules
  # ---------------------------------------------------------------------------
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.kernelModules = ["kvm-amd"];
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod" "sdhci_pci"];
  boot.initrd.kernelModules = lib.mkIf (env.enableEarlyKms or false) ["amdgpu"];

  # ---------------------------------------------------------------------------
  # 🖥️ AMD GPU Optimizations & Video Drivers
  # ---------------------------------------------------------------------------
  boot.kernelParams = [
    "amdgpu.sg_display=0" # Fix APU green frame drops
    "amdgpu.dcdebugmask=0x410" # Disable PSR + SubVP clock transition hitching
    "amdgpu.abmlevel=0" # Disable adaptive backlight contrast shifts
  ];

  services.xserver.videoDrivers = ["amdgpu"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
      libvdpau-va-gl
    ];
  };

  # ---------------------------------------------------------------------------
  # 📁 Filesystems & Storage
  # ---------------------------------------------------------------------------
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fe3677e4-2898-4681-ad1e-b16c6dc5f847";
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
      "lazytime"
      "commit=300"
    ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0A74-D9B0";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
