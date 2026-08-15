# =============================================================================
#  Virtualization, Container Engines & VM Testing Environment
# =============================================================================
{
  config,
  pkgs,
  pkgList,
  lib,
  username,
  enableWaydroid,
  enableLibvirt,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 📁 Kernel Filesystem Sharing Modules
  # ---------------------------------------------------------------------------
  boot.kernelModules = [
    "virtiofs"
    "9p"
    "9pnet"
    "9pnet_virtio"
  ];

  # ---------------------------------------------------------------------------
  # 🦭 Podman Container Engine (Rootless Docker Replacement)
  # ---------------------------------------------------------------------------
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.containers.enable = true;

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
  systemd.services.waydroid-container.environment.LXC_USE_NFT = "true";

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
  systemd.services.libvirtd.wantedBy = lib.mkForce [];

  # SPICE USB Passthrough for QEMU/KVM
  virtualisation.spiceUSBRedirection.enable = enableLibvirt;

  # Virt-Manager GUI Tool
  programs.virt-manager.enable = enableLibvirt;

  # Virtualization Package List
  environment.systemPackages = (pkgList pkgs).virtualization;

  # SPICE Guest Clipboard Agent
  services.spice-vdagentd.enable = enableLibvirt;

  # ---------------------------------------------------------------------------
  # 🧪 VM Testing Configuration (Applied only during `just vm`)
  # ---------------------------------------------------------------------------
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 4;
    };
    # Explicit user password for the test VM instance
    users.users.${username}.password = "rsh";
  };
}
