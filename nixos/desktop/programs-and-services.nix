{pkgs, ...}: {
  # System Program Enablements & Integrations
  programs = {
    nh.enable = true;
    niri.enable = true;
    nix-ld.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  # System Service Enablements
  # Display Manager (Ly display manager with Niri session)
  services = {
    displayManager = {
      defaultSession = "niri";
      ly.enable = true;
    };

    # System Utilities & Network Discovery
    avahi.enable = true;
  };
}
