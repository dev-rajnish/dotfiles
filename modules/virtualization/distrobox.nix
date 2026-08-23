{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.mySystem.virtualization.distrobox;
in {
  options.mySystem.virtualization.distrobox = {
    enable = lib.mkEnableOption "distrobox config";
  };

  config = lib.mkIf cfg.enable {
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
  };
}
