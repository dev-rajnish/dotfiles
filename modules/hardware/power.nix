{ config, 
  lib,
  pkgs,
  env,
  ...
}:
let
  cfg = config.mySystem.hardware.power;
in {
  options.mySystem.hardware.power = {
    enable = lib.mkEnableOption "power config";
  };

  config = lib.mkIf cfg.enable (
    lib.mkIf (env.enableLidInhibit or false) {
  # ---------------------------------------------------------------------------
  # 🚀 Kernel Parameters to Prevent EC Wakeup on Lid Events
  # ---------------------------------------------------------------------------
  boot.kernelParams = [
    "acpi.ec_no_wakeup=1" # Prevent Embedded Controller (EC) from waking s2idle on lid events
    "button.lid_init_state=method" # Query ACPI method for lid state rather than interrupt notifications
  ];

  # ---------------------------------------------------------------------------
  # 🧰 Udev Rules to Silence Lid Switch at Kernel Input Layer
  # ---------------------------------------------------------------------------
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", ATTR{name}=="Lid Switch", ATTR{inhibited}="1"
  '';

  # ---------------------------------------------------------------------------
  # 🛡️ Systemd Logind Lid Action Suppression
  # ---------------------------------------------------------------------------
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    LidSwitchIgnoreInhibited = "no";
    # Options: "ignore", "suspend", "lock", "hibernate"
    HandlePowerKey = "ignore";

    # Require holding the power button for power off:
    HandlePowerKeyLongPress = "poweroff";
  };

  # ---------------------------------------------------------------------------
  # ⚡ Disable ACPI, I2C Sensor & Input Wakeups Before Every Sleep / Suspend
  # ---------------------------------------------------------------------------
  systemd.services.disable-lid-touchpad-wakeups = {
    description = "Disable ACPI and I2C Sensor False Wakeups from Suspend";
    wantedBy = [
      "sleep.target"
      "suspend.target"
    ];
    before = [
      "sleep.target"
      "suspend.target"
    ];
    script = ''
      # Inhibit Lid Switch input device at kernel driver layer so it emits zero events
      for f in /sys/class/input/input*/inhibited; do
        dev_dir=$(dirname "$f")
        if [ "$(cat "$dev_dir/name" 2>/dev/null)" = "Lid Switch" ]; then
          echo 1 > "$f" || true
        fi
      done

      # Disable legacy ACPI wakeup sources (LID0, Wi-Fi, USB, Storage, Touchpad)
      for dev in LID0 GPP1 GPP6 GPP7 XHC0 XHC1 XHC2 XHC3 XHC4 GP19; do
        if grep -q "^$dev.*enabled" /proc/acpi/wakeup 2>/dev/null; then
          echo "$dev" > /proc/acpi/wakeup || true
        fi
      done

      # Disable modern s2idle I2C Sensor & Touchpad wakeups (ITE8350 Hall Lid sensor & ELAN06FA)
      for f in /sys/bus/i2c/devices/*/power/wakeup /sys/devices/platform/AMDI0010:*/i2c-*/i2c-*/power/wakeup /sys/devices/platform/USBC000:*/power_supply/*/power/wakeup; do
        if [ -f "$f" ]; then
          echo disabled > "$f" || true
        fi
      done
    '';
    serviceConfig.Type = "oneshot";
  };
}
  );
}
