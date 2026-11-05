# =============================================================================
#  Intel Host Configuration (modules/hosts/intel.nix)
#  Secondary machine profile for Intel CPU + Intel GPU (Friend's Laptop)
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
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.kernelModules = ["kvm-intel"];
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod" "sdhci_pci"];
  boot.initrd.kernelModules = lib.mkIf (env.enableEarlyKms or false) ["i915"];

  # ---------------------------------------------------------------------------
  # 🖥️ Intel GPU Modesetting & Acceleration
  # ---------------------------------------------------------------------------
  services.xserver.videoDrivers = ["modesetting"];

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

  # ---------------------------------------------------------------------------
  # 📁 Filesystems & Storage (Configured per host disk layout)
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
