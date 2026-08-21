{ config, 
  pkgs,
  lib,
  env,
  ...
}:
let
  cfg = config.mySystem.virtualization.appimage;
in {
  options.mySystem.virtualization.appimage = {
    enable = lib.mkEnableOption "appimage config";
  };

  config = lib.mkIf cfg.enable (
    let
  enableAppImage = env.enableAppImage or true;
in {
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
    appimage-run
    squashfsTools
    fuse3
  ]);
}
  );
}
