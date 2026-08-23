{
  config,
  lib,
  pkgs,
  env,
  ...
}: let
  cfg = config.mySystem.system.user-accounts;
in {
  options.mySystem.system.user-accounts = {
    enable = lib.mkEnableOption "user-accounts config";
  };

  config = lib.mkIf cfg.enable {
    users.groups.adbusers = {};

    users.users = {
      # -------------------------------------------------------------------------
      # 👤 Primary User Account
      # -------------------------------------------------------------------------
      ${env.username} = {
        isNormalUser = true;
        initialPassword = env.username;
        shell = pkgs.fish;
        ignoreShellProgramCheck = true;

        description = env.username;

        # Permission groups for hardware, virtualization, and audio
        extraGroups = [
          "networkmanager" # Network management
          "wheel" # Sudo / Root privileges
          "video" # GPU & Display access
          "render" # DRM / Hardware rendering
          "input" # Input devices & KMonad
          "podman" # Rootless containers
          "seat" # Seatd daemon access
          "adbusers" # Android ADB / Fastboot
          "kvm" # Kernel Virtual Machine
          "libvirtd" # Libvirt virtualization
          "audio" # PipeWire / ALSA audio
        ];
      };

      # -------------------------------------------------------------------------
      # 👑 Root Superuser Account
      # -------------------------------------------------------------------------
      root = {
        initialPassword = "nixos";
      };
    };
  };
}
