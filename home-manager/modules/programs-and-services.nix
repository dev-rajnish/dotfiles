{pkgs, ...}: {
  # Home Manager Program Enablements
  programs = {
    home-manager.enable = true;
    bash.enable = true;
    atuin.enable = true;

    eza = {
      enable = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    man.enable = false;
  };

  # Home Manager User Service Enablements
  services = {
    wayle.autoInstallDependencies = true;
  };

  manual.manpages.enable = false;
  systemd.user.startServices = "sd-switch";
}
