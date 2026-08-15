# =============================================================================
#  Bootloader, Kernel, Audio, Power & System Services
# =============================================================================
{
  pkgs,
  config,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 1. 🚀 Bootloader & Kernel Configuration
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
  # 2. ⚡ ZRAM Memory Swap Compression
  # ---------------------------------------------------------------------------
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # ---------------------------------------------------------------------------
  # 3. 🎯 Realtime Privileges (rtkit)
  # ---------------------------------------------------------------------------
  security.rtkit.enable = true;

  # ---------------------------------------------------------------------------
  # 4. 🧰 Hardware Services & Display Server
  # ---------------------------------------------------------------------------
  services = {
    # Libinput touchpad & pointer driver
    libinput.enable = true;

    # XServer keyboard layout (when used)
    xserver = {
      enable = false;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    # Console Display (KMSCon)
    kmscon = {
      enable = false;
      fonts = [
        {
          name = "JetBrains Mono";
          package = pkgs.jetbrains-mono;
        }
      ];
      extraOptions = "--term xterm-256color --font-size=18";
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
    upower.ignoreLid = true;
    power-profiles-daemon.enable = true;

    # Ignore Lid events in systemd-logind to prevent false actions
    logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };

    # -------------------------------------------------------------------------
    # 5. 🎵 PipeWire Low-Latency Audio Server
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
  # 6. ⏱️ Systemd Backlight, Fast Shutdown Timeouts & ACPI Wakeups Disable
  # ---------------------------------------------------------------------------
  systemd.services."systemd-backlight@".enable = false;
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "3s";
  };

  # Disable ACPI wakeup triggers (Lid, Wi-Fi, USB, Touchpad, NVMe) before every sleep & boot
  systemd.services.disable-acpi-wakeups = {
    description = "Disable ACPI False Wakeups from Suspend";
    wantedBy = [
      "multi-user.target"
      "sleep.target"
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
    before = [
      "sleep.target"
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
    script = ''
      # Disable lid, wifi, usb ports, touchpad, and storage wakeups if currently enabled
      for dev in LID0 GPP1 GPP6 GPP7 XHC0 XHC1 XHC2 XHC3 XHC4 GP19; do
        if grep -q "^$dev.*enabled" /proc/acpi/wakeup 2>/dev/null; then
          echo "$dev" > /proc/acpi/wakeup || true
        fi
      done
    '';
    serviceConfig.Type = "oneshot";
  };
}
