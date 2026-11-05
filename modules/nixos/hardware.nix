# =============================================================================
#  Hardware Services Module (modules/nixos/hardware.nix)
#  Manages Bluetooth and Power/Lid Inhibit policies
# =============================================================================
{
  config,
  lib,
  pkgs,
  env,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 📡 Bluetooth Hardware Daemon & Power Configuration
  # ---------------------------------------------------------------------------
  hardware.bluetooth = lib.mkIf (env.enableBluetooth or false) {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };
  services.blueman.enable = env.enableBluetooth or false;

  # ---------------------------------------------------------------------------
  # ⚡ Power Management & Lid Switch Inhibit
  # ---------------------------------------------------------------------------
  boot.kernelParams = lib.mkIf (env.enableLidInhibit or false) [
    "acpi.ec_no_wakeup=1"
    "button.lid_init_state=method"
  ];

  services.udev.extraRules = lib.mkIf (env.enableLidInhibit or false) ''
    ACTION=="add", SUBSYSTEM=="input", ATTR{name}=="Lid Switch", ATTR{inhibited}="1"
  '';

  services.logind.settings.Login = lib.mkIf (env.enableLidInhibit or false) {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    LidSwitchIgnoreInhibited = "no";
    HandlePowerKey = "ignore";
    HandlePowerKeyLongPress = "poweroff";
  };

  systemd.services.disable-lid-touchpad-wakeups = lib.mkIf (env.enableLidInhibit or false) {
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
      for f in /sys/class/input/input*/inhibited; do
        dev_dir=$(dirname "$f")
        if [ "$(cat "$dev_dir/name" 2>/dev/null)" = "Lid Switch" ]; then
          echo 1 > "$f" || true
        fi
      done

      for dev in LID0 GPP1 GPP6 GPP7 XHC0 XHC1 XHC2 XHC3 XHC4 GP19; do
        if grep -q "^$dev.*enabled" /proc/acpi/wakeup 2>/dev/null; then
          echo "$dev" > /proc/acpi/wakeup || true
        fi
      done

      for f in /sys/bus/i2c/devices/*/power/wakeup /sys/devices/platform/AMDI0010:*/i2c-*/i2c-*/power/wakeup /sys/devices/platform/USBC000:*/power_supply/*/power/wakeup; do
        if [ -f "$f" ]; then
          echo disabled > "$f" || true
        fi
      done
    '';
    serviceConfig.Type = "oneshot";
  };
}
