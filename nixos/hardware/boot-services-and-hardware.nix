{pkgs, ...}: {
  # Bootloader Configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = ["snd_hda_intel.power_save=0"];
    # Kernel & Temporary Filesystem
    kernelPackages = pkgs.linuxPackages_latest;
    tmp = {
      tmpfsHugeMemoryPages = "always";
      useZram = true;
    };
  };

  # Memory & Virtualisation
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  virtualisation.podman.enable = true;

  # Security & Realtime Privileges
  security.rtkit.enable = true;

  # System Services Configuration
  services = {
    # Input & Display Server
    libinput.enable = true;
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    # Console Display
    kmscon = {
      enable = false;
      fonts = [
        {
          name = "Source Code Pro";
          package = pkgs.source-code-pro;
        }
      ];
      extraOptions = "--term xterm-256color";
    };

    # Hardware & Power Management
    fstrim.enable = true;
    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
    gvfs.enable = true;
    udev.extraRules = ''SUBSYSTEM=="usb", ATTR{idVendor}=="2717", MODE="0666", GROUP="adbusers"'';

    upower.enable = true;
    power-profiles-daemon.enable = true;

    # Audio Configuration (Pipewire)
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    # Journald Storage Limits
    journald.extraConfig = ''
      SystemMaxUse=100M
      RuntimeMaxUse=50M
      MaxRetentionSec=1month
    '';
  };
}
