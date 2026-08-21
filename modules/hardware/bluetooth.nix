{ config,  lib, 
  pkgs,
  env,
  ...
}:
let
  cfg = config.mySystem.hardware.bluetooth;
in {
  options.mySystem.hardware.bluetooth = {
    enable = lib.mkEnableOption "bluetooth config";
  };

  config = lib.mkIf cfg.enable (
    {
  # ---------------------------------------------------------------------------
  # 📡 Bluetooth Hardware Daemon & Power Configuration
  # ---------------------------------------------------------------------------
  hardware.bluetooth = {
    enable = env.enableBluetooth or false;
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
  services.blueman.enable = env.enableBluetooth or false;
}
  );
}
