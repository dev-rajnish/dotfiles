# =============================================================================
#  Virtualization, Container Engines & VM Testing Environment
# =============================================================================
{
  config,
  pkgs,
  pkgList,
  lib,
  username,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 1. 📁 Kernel Filesystem Sharing Modules
  # ---------------------------------------------------------------------------
  boot.kernelModules = [
    "virtiofs"
    "9p"
    "9pnet"
    "9pnet_virtio"
  ];

  # ---------------------------------------------------------------------------
  # 2. 🦭 Podman Container Engine (Rootless Docker Replacement)
  # ---------------------------------------------------------------------------
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.containers.enable = true;

  # ---------------------------------------------------------------------------
  # 3. 🤖 Waydroid Android Container
  # ---------------------------------------------------------------------------
  virtualisation.waydroid.enable = true;
  systemd.services.waydroid-container.environment.LXC_USE_NFT = "true";
  virtualisation.waydroid.package =
    if config.networking.nftables.enable
    then pkgs.waydroid-nftables
    else pkgs.waydroid;

  # ---------------------------------------------------------------------------
  # 4. ⚡ QEMU / KVM & Libvirt Hypervisor
  # ---------------------------------------------------------------------------
  virtualisation.libvirtd = {
    enable = true;
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
  virtualisation.spiceUSBRedirection.enable = true;

  # Virt-Manager GUI Tool
  programs.virt-manager.enable = true;

  # Virtualization Package List
  environment.systemPackages = (pkgList pkgs).virtualization;

  # SPICE Guest Clipboard Agent
  services.spice-vdagentd.enable = true;

  # ---------------------------------------------------------------------------
  # 5. 🧪 VM Testing Configuration (Applied only during `just vm`)
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
