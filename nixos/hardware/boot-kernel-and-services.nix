# =============================================================================
#  Bootloader, Kernel, Audio, Console Typography & Core System Services
# =============================================================================
{
  pkgs,
  config,
  keyboardLayout,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🚀 Bootloader & Kernel Configuration
  # ---------------------------------------------------------------------------
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = ["snd-aloop"];
    kernelParams = [
      "snd_hda_intel.power_save=0" # Prevent audio popping on power state change
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    tmp = {
      tmpfsHugeMemoryPages = "always";
      useZram = true;
    };
  };

  # ---------------------------------------------------------------------------
  # 🖥️ Linux Virtual Console / TTY Typography
  # ---------------------------------------------------------------------------
  console = {
    enable = true;
    packages = [pkgs.terminus_font];
    font = "ter-v32n"; # Large HiDPI Terminus bitmap font for crisp early boot console
  };

  # ---------------------------------------------------------------------------
  # ⚡ ZRAM Memory Swap Compression
  # ---------------------------------------------------------------------------
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # ---------------------------------------------------------------------------
  # 🎯 Realtime Privileges (rtkit)
  # ---------------------------------------------------------------------------
  security.rtkit.enable = true;

  # ---------------------------------------------------------------------------
  # 🧰 Hardware Services & Display Server
  # ---------------------------------------------------------------------------
  services = {
    # Libinput touchpad & pointer driver
    libinput.enable = true;

    # XServer keyboard layout (when used)
    xserver = {
      enable = false;
      xkb = {
        layout = keyboardLayout;
        variant = "";
      };
    };

    # SSD TRIM automation
    fstrim.enable = true;

    # Removable drive auto-mounting
    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
    gvfs.enable = true;

    # Udev rule for ADB access on Android devices
    udev.extraRules = ''SUBSYSTEM=="usb", ATTR{idVendor}=="2717", MODE="0666", GROUP="adbusers"'';

    # Power Management & Dynamic Profiles
    upower.enable = true;
    power-profiles-daemon.enable = true;

    # -------------------------------------------------------------------------
    # 🎵 PipeWire Low-Latency Audio Server
    # -------------------------------------------------------------------------
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

    # System Journal Limits
    journald.extraConfig = ''
      SystemMaxUse=100M
      RuntimeMaxUse=50M
      MaxRetentionSec=1month
    '';
  };

  # ---------------------------------------------------------------------------
  # ⏱️ Systemd Backlight & Fast Shutdown Timeouts
  # ---------------------------------------------------------------------------
  systemd.services."systemd-backlight@".enable = false;
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "3s";
  };
}
