# =============================================================================
#  Distrobox & Podman Rootless Container Subsystem
# =============================================================================
{pkgs, ...}: {
  # ---------------------------------------------------------------------------
  # 🦭 Podman Container Engine (Rootless Docker Replacement)
  # ---------------------------------------------------------------------------
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.containers.enable = true;

  # Packages needed for Distrobox container workflows
  environment.systemPackages = with pkgs; [
    distrobox
    podman
  ];
}
