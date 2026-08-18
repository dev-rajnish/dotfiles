# =============================================================================
#  NixOS Virtualization Sub-Modules Entrypoint
# =============================================================================
{
  imports = [
    ./android-waydroid.nix
    ./appimage.nix
    ./containers-distrobox.nix
    ./hypervisor-libvirt.nix
    ./vm-build-runner.nix
  ];
}
