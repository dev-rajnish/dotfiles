{
  config,
  pkgs,
  pkgList,
  ...
}: {
  # Filesystem Sharing Modules
  boot.kernelModules = [
    "virtiofs"
    "9p"
    "9pnet"
    "9pnet_virtio"
  ];

  # Podman Container Engine
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.containers.enable = true;

  # Waydroid Android Container
  virtualisation.waydroid.enable = true;
  systemd.services.waydroid-container.environment.LXC_USE_NFT = "true";
  virtualisation.waydroid.package =
    if config.networking.nftables.enable
    then pkgs.waydroid-nftables
    else pkgs.waydroid;

  # QEMU / KVM & Libvirt Hypervisor
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  # SPICE USB Passthrough for QEMU/KVM
  virtualisation.spiceUSBRedirection.enable = true;

  # Virt-Manager GUI Tool
  programs.virt-manager.enable = true;

  # Virtualization Package List
  environment.systemPackages = (pkgList pkgs).virtualization;

  # SPICE Agent for Guest Clipboard
  services.spice-vdagentd.enable = true;
}
