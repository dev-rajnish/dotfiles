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
  # 📁 Filesystems & Storage (Standardized by-label layout)
  # ---------------------------------------------------------------------------
  fileSystems."/" = {
    device = lib.mkDefault "/dev/disk/by-label/nixos";
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
    device = lib.mkDefault "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # ---------------------------------------------------------------------------
  # 🎵 Conexant SN6140 Audio Hardware Initialization
  # ---------------------------------------------------------------------------
  boot.postBootCommands = ''
    ${pkgs.alsa-utils}/bin/amixer -c Generic_1 sset 'Auto-Mute Mode' 'Disabled' 2>/dev/null || true
    ${pkgs.alsa-utils}/bin/amixer -c Generic_1 sset 'Headphone' unmute 2>/dev/null || true
  '';
}
