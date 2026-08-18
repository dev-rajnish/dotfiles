# =============================================================================
#  Home Manager User Package Aggregation
# =============================================================================
{
  pkgs,
  pkgList,
  env,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🌟 Consolidated User Packages (Imported from env/packages.nix -> hmPackages)
  # ---------------------------------------------------------------------------
  home.packages =
    (pkgList {
      inherit pkgs;
      inherit (env) enableDevPkg enableProgrammingLang;
    }).hmPackages;

  # Home Manager self-management & command lookup
  programs.home-manager.enable = true;
  programs.nix-index.enable = true;

  # Documentation / manpages build settings
  programs.man.enable = false;
  manual.manpages.enable = false;
}
