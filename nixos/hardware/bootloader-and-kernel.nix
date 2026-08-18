# =============================================================================
#  Bootloader, Kernel, Audio, Console Typography & Core System Services
# =============================================================================
{
  pkgs,
  config,
  env,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🚀 Bootloader & Kernel Configuration
  # ---------------------------------------------------------------------------
  boot = {
    loader = {
      systemd-boot.enable = true;
      timeout = 1; # Set to 0s for fast boot (hold Space on power-on for menu)
      efi.canTouchEfiVariables = true;
    };
    initrd.systemd.enable = true; # Parallelized stage-1 systemd initialization
    kernelModules = ["snd-aloop"];
    kernelParams = [
      #"snd_hda_intel.power_save=0" # Prevent audio codec power state change
      #"snd_hda_intel.power_save_controller=0" # Prevent audio controller D3 power state change
      #"snd_hda_intel.position_fix=1" # Fix Conexant SN6140 DMA pointer drift on AMD HD Audio
    ];
    # extraModprobeConfig = ''
    #  options snd_hda_intel power_save=0 power_save_controller=N position_fix=1
    # '';
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
        layout = env.keyboardLayout;
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
      wireplumber = {
        enable = true;
        extraConfig = {
          "10-disable-suspension" = {
            "monitor.alsa.rules" = [
              {
                matches = [
                  {
                    "node.name" = "~alsa_input.*";
                  }
                  {
                    "node.name" = "~alsa_output.*";
                  }
                ];
                actions = {
                  update-props = {
                    "session.suspend-timeout-seconds" = 0;
                  };
                };
              }
            ];
          };
        };
      };
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
