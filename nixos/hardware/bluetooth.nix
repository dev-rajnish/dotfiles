# =============================================================================
#  Bluetooth Subsystem Configuration (BlueZ & Hardware Management)
# =============================================================================
{
  pkgs,
  enableBluetooth,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 📡 Bluetooth Hardware Daemon & Power Configuration
  # ---------------------------------------------------------------------------
  hardware.bluetooth = {
    enable = enableBluetooth;
    powerOnBoot = true; # Automatically power on Bluetooth controller on boot
    settings = {
      General = {
        # Enable battery reporting for connected Bluetooth headsets and devices
        Experimental = true;
        # Fast connectable for low-latency reconnects
        FastConnectable = true;
      };
      Policy = {
        # Auto-enable Bluetooth adapter when powered on
        AutoEnable = true;
      };
    };
  };

  # ---------------------------------------------------------------------------
  # 🧰 Bluetooth GUI & Management Integration
  # ---------------------------------------------------------------------------
  services.blueman.enable = enableBluetooth;
}
