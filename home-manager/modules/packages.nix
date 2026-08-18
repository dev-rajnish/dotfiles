# =============================================================================
#  Home Manager User Package Aggregation
# =============================================================================
{
  pkgs,
  pkgList,
  enableDevPkg ? true,
  enableProgrammingLang ? true,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🌟 Consolidated User Packages (Imported from 1-package-manifest.nix -> hmPackages)
  # ---------------------------------------------------------------------------
  home.packages = (pkgList {inherit pkgs enableDevPkg enableProgrammingLang;}).hmPackages;

  # Home Manager self-management & command lookup
  programs.home-manager.enable = true;
  programs.nix-index.enable = true;

  # Documentation / manpages build settings
  programs.man.enable = false;
  manual.manpages.enable = false;
}
