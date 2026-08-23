{
  lib,
  pkgs,
  config,
  env,
  ...
}: let
  cfg = config.mySystem.system.boot-and-kernel;
in {
  options.mySystem.system.boot-and-kernel = {
    enable = lib.mkEnableOption "boot-and-kernel config";
  };

  config = lib.mkIf cfg.enable {
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
        "systemd.swap=0" # Prevent systemd from auto-activating physical SSD swap partitions
      ];
      kernelPackages = pkgs.linuxPackages_latest;
      kernel.sysctl = {
        # ⚡ SSD Write Endurance Optimizations (Ultra-Long 30-Minute Dirty Writeback & RAM Cache)
        "vm.dirty_writeback_centisecs" = 180000; # 30 minutes (1,800s)
        "vm.dirty_expire_centisecs" = 180000; # 30 minutes (1,800s)
        "vm.vfs_cache_pressure" = 20; # Keep directory/inode cache in RAM
        "vm.dirty_background_ratio" = 15; # Flush to disk only when dirty memory > 15%
        "vm.dirty_ratio" = 30; # Hard limit 30% dirty memory
        "vm.swappiness" = 180; # Use fast compressed ZRAM swap in RAM
        "vm.laptop_mode" = 5; # Delay disk writes until read/sync occurs
      };
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
    # ⚡ ZRAM Memory Swap Compression (100% in RAM, Zero SSD Swap Writes)
    # ---------------------------------------------------------------------------
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 100;
      priority = 100;
    };

    # ---------------------------------------------------------------------------
    # 💾 In-Memory Crash Core Dumps (Tmpfs in RAM - Zero SSD Writes)
    # ---------------------------------------------------------------------------
    systemd.coredump = {
      enable = true;
      settings.Coredump = {
        Storage = "memory";
        ProcessSizeMax = "500M";
        ExternalSizeMax = "500M";
        JournalSizeMax = "50M";
        MaxUse = "250M";
      };
    };

    fileSystems."/var/lib/systemd/coredump" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "mode=0755"
        "size=500M"
        "x-gvfs-hide"
      ];
      neededForBoot = false;
    };

    # ---------------------------------------------------------------------------
    # 📜 System Logs in RAM (100M Tmpfs - Zero SSD Wear)
    # ---------------------------------------------------------------------------
    fileSystems."/var/log" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "mode=0755"
        "size=100M"
        "x-gvfs-hide"
      ];
      neededForBoot = false;
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

      # 📝 System Journal Limits (In-Memory Volatile Storage - Zero SSD Log Wear)
      journald.extraConfig = ''
        Storage=volatile
        RuntimeMaxUse=32M
        RateLimitIntervalSec=30s
        RateLimitBurst=1000
      '';
    };

    # ---------------------------------------------------------------------------
    # ⏱️ Systemd Backlight & Fast Shutdown Timeouts
    # ---------------------------------------------------------------------------
    systemd.services."systemd-backlight@".enable = false;
    systemd.settings.Manager = {
      DefaultTimeoutStopSec = "2s";
    };

    # ---------------------------------------------------------------------------
    # 🔄 Flush In-Memory Journal to SSD Only on Shutdown / Reboot (Zero Runtime Writes)
    # ---------------------------------------------------------------------------
    systemd.services."journal-flush-on-shutdown" = {
      description = "Flush In-Memory Journal Logs to SSD on Shutdown";
      wantedBy = ["multi-user.target"];
      after = ["systemd-journald.service"];
      unitConfig = {
        DefaultDependencies = "no";
      };
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.coreutils}/bin/mkdir -p /var/log/journal /run/log/journal";
        ExecStop = pkgs.writeShellScript "journal-shutdown-sync" ''
          set -euo pipefail
          if [ -d "/run/log/journal" ]; then
            ${pkgs.coreutils}/bin/mkdir -p /var/log/journal
            ${pkgs.rsync}/bin/rsync -a /run/log/journal/ /var/log/journal/ 2>/dev/null || true
          fi
        '';
        TimeoutStopSec = "5s";
      };
    };
  };
}
