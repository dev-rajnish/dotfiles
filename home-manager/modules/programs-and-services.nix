# =============================================================================
#  Home Manager Programs, Services & User Package Aggregation
# =============================================================================
{
  pkgs,
  pkgList,
  enableDevPkg ? true,
  enableProgrammingLang ? true,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🌟 Consolidated User Packages (Imported from 1-pkg-list.nix -> hmPackages)
  # ---------------------------------------------------------------------------
  home.packages = (pkgList {inherit pkgs enableDevPkg enableProgrammingLang;}).hmPackages;

  # ---------------------------------------------------------------------------
  # 🛠️ Home Manager Program Enablements & Shell Integrations
  # ---------------------------------------------------------------------------
  programs = {
    # Home Manager self-management
    home-manager.enable = true;
    nix-index.enable = true;

    # Bash compatibility
    bash.enable = true;

    # Atuin Shell History Sync & Search
    atuin.enable = true;

    # Eza modern ls replacement
    eza = {
      enable = true;
      enableFishIntegration = true;
    };

    # Zoxide smart directory jumper
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    # Disable standalone manpage build
    man.enable = false;
  };

  # ---------------------------------------------------------------------------
  # 📡 Home Manager User Service Enablements
  # ---------------------------------------------------------------------------
  services = {
    # Wayle Wayland status bar daemon
    wayle.autoInstallDependencies = true;
  };

  manual.manpages.enable = false;

  # Automatically restart user systemd services on configuration change
  systemd.user.startServices = "sd-switch";
}
