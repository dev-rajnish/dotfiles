# =============================================================================
#  AppImage Sandboxing & Execution Subsystem
# =============================================================================
{
  pkgs,
  lib,
  enableAppImage ? true,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 📦 AppImage Execution Engine & Kernel Binfmt Integration
  # ---------------------------------------------------------------------------
  programs.appimage = {
    enable = enableAppImage;
    binfmt = enableAppImage;
    package = pkgs.appimage-run;
  };

  # Enable FUSE user mount permissions (required for AppImage SquashFS payloads)
  programs.fuse.userAllowOther = lib.mkIf enableAppImage true;

  # Load FUSE kernel module for mounting AppImage filesystems
  boot.kernelModules = lib.optionals enableAppImage ["fuse"];

  # ---------------------------------------------------------------------------
  # 🛠️ AppImage Utilities
  # ---------------------------------------------------------------------------
  environment.systemPackages = lib.optionals enableAppImage (with pkgs; [
    appimage-run # CLI launcher for unpatched binary AppImages on NixOS
    squashfsTools # Extraction & inspection tools for AppImage files
    fuse3 # Modern user-space filesystem library
  ]);
}
