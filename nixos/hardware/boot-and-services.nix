{
  pkgs,
  config,
  ...
}: {
  # Bootloader & Kernel Configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = ["snd-aloop"];
    kernelParams = [
      "snd_hda_intel.power_save=0"
      "snd_hda_intel.power_save_controller=0"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    tmp = {
      tmpfsHugeMemoryPages = "always";
      useZram = true;
    };
  };

  # ZRAM Memory Swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Realtime Privileges (rtkit)
  security.rtkit.enable = true;

  # Hardware Services & Display
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

    # Pipewire Audio Server
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

  # Systemd Backlight & Timeout Settings
  systemd.services."systemd-backlight@".enable = false;
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "3s";
  };
}
