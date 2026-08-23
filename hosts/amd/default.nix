# =============================================================================
#  AMD Host Configuration
# =============================================================================
{...}: {
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  # Machine-Specific Hardware Profile
  mySystem.hardware.amd.enable = true;
}
