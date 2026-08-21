{ config, 
  pkgs,
  lib,
  env,
  ...
}:
let
  cfg = config.mySystem.virtualization.libvirt;
in {
  options.mySystem.virtualization.libvirt = {
    enable = lib.mkEnableOption "libvirt config";
  };

  config = lib.mkIf cfg.enable (
    let
  enableLibvirt = env.enableLibvirt or true;
in {
  # ---------------------------------------------------------------------------
  # 📁 Kernel Filesystem Sharing Modules for VM Guest Mounts
  # ---------------------------------------------------------------------------
  boot.kernelModules = [
    "virtiofs"
    "9p"
    "9pnet"
    "9pnet_virtio"
  ];

  # ---------------------------------------------------------------------------
  # ⚡ QEMU / KVM & Libvirt Hypervisor
  # ---------------------------------------------------------------------------
  virtualisation.libvirtd = {
    enable = enableLibvirt;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true; # Software TPM 2.0 emulator for Windows 11 VMs
    };
  };

  # Prevent libvirtd service from starting automatically on boot
  # (Socket activation starts it on-demand when virt-manager is launched)
  systemd.services.libvirtd.wantedBy = lib.mkIf enableLibvirt (lib.mkForce []);

  # SPICE USB Passthrough
  virtualisation.spiceUSBRedirection.enable = enableLibvirt;
  services.spice-vdagentd.enable = false;

  # Virt-Manager GUI Tool
  programs.virt-manager.enable = enableLibvirt;

  # Virtualization Client & USB Utilities
  environment.systemPackages = with pkgs; [
    virt-viewer
    virtiofsd
    usbredir
    usbutils
  ];
}
  );
}
