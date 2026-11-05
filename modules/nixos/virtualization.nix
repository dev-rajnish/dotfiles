# =============================================================================
#  Virtualization & Container Engines Module (modules/nixos/virtualization.nix)
#  Manages Podman/Distrobox, Libvirt/KVM, Waydroid, AppImage, and VM runner
# =============================================================================
{
  config,
  pkgs,
  lib,
  env,
  ...
}: let
  enableDistrobox = env.enableDistrobox or true;
  enableLibvirt = env.enableLibvirt or true;
  enableWaydroid = env.enableWaydroid or false;
  enableAppImage = env.enableAppImage or true;
in {
  # ---------------------------------------------------------------------------
  # 🦭 Podman Container Engine & Distrobox
  # ---------------------------------------------------------------------------
  virtualisation.podman = lib.mkIf enableDistrobox {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.containers.enable = lib.mkIf enableDistrobox true;

  # ---------------------------------------------------------------------------
  # ⚡ QEMU / KVM & Libvirt Hypervisor
  # ---------------------------------------------------------------------------
  boot.kernelModules =
    (lib.optionals enableLibvirt [
      "virtiofs"
      "9p"
      "9pnet"
      "9pnet_virtio"
    ])
    ++ (lib.optionals enableAppImage [
      "fuse"
    ]);

  virtualisation.libvirtd = lib.mkIf enableLibvirt {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  systemd.services.libvirtd.wantedBy = lib.mkIf enableLibvirt (lib.mkForce []);
  virtualisation.spiceUSBRedirection.enable = enableLibvirt;
  services.spice-vdagentd.enable = false;

  programs.virt-manager.enable = enableLibvirt;

  # ---------------------------------------------------------------------------
  # 📦 Unified Virtualization Packages
  # ---------------------------------------------------------------------------
  environment.systemPackages =
    (lib.optionals enableDistrobox (with pkgs; [
      distrobox
      podman
    ]))
    ++ (lib.optionals enableLibvirt (with pkgs; [
      virt-viewer
      virtiofsd
      usbredir
      usbutils
    ]))
    ++ (lib.optionals enableAppImage (with pkgs; [
      appimage-run
      squashfsTools
      fuse3
    ]));

  # ---------------------------------------------------------------------------
  # 🤖 Waydroid Android Container
  # ---------------------------------------------------------------------------
  virtualisation.waydroid = lib.mkIf enableWaydroid {
    enable = true;
    package =
      if config.networking.nftables.enable
      then pkgs.waydroid-nftables
      else pkgs.waydroid;
  };
  systemd.services.waydroid-container.environment.LXC_USE_NFT = lib.mkIf enableWaydroid "true";

  # ---------------------------------------------------------------------------
  # 📦 AppImage Execution Engine & Kernel Binfmt
  # ---------------------------------------------------------------------------
  programs.appimage = lib.mkIf enableAppImage {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run;
  };
  programs.fuse.userAllowOther = lib.mkIf enableAppImage true;

  # ---------------------------------------------------------------------------
  # 🧪 VM Runner Variant (Applied only during `just vm` / `nixos-rebuild build-vm`)
  # ---------------------------------------------------------------------------
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 4;
    };
    users.users.${env.username}.initialPassword = env.username;
  };
}
