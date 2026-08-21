{ config,  lib, username, ...}:
let
  cfg = config.mySystem.virtualization.vm-runner;
in {
  options.mySystem.virtualization.vm-runner = {
    enable = lib.mkEnableOption "vm-runner config";
  };

  config = lib.mkIf cfg.enable (
    {
  # ---------------------------------------------------------------------------
  # 🧪 VM Testing Configuration (Applied only during `just vm` / `nixos-rebuild build-vm`)
  # ---------------------------------------------------------------------------
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 4;
    };
    # Set matching user credentials inside the test VM
    users.users.${username}.initialPassword = username;
  };
}
  );
}
