# =============================================================================
#  User Accounts, Permission Groups & Shell Configuration
# =============================================================================
{
  username,
  pkgs,
  ...
}: {
  users.users = {
    # -------------------------------------------------------------------------
    # 👤 Primary User Account
    # -------------------------------------------------------------------------
    ${username} = {
      isNormalUser = true;
      initialPassword = username;
      shell = pkgs.bash;
      ignoreShellProgramCheck = true;

      description = username;

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
}
