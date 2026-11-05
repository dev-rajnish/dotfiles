# =============================================================================
#  Common Host Configuration (Shared across all machines)
# =============================================================================
{env, ...}: {
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = env.stateVersion;
  home-manager.users.${env.username}.home.stateVersion = env.stateVersion;
}
