# =============================================================================
#  NixOS Test VM Variant Environment (`just vm`)
# =============================================================================
{username, ...}: {
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
