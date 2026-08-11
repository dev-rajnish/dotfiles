{
  pkgs,
  pkgList,
  ...
}: let
  pkgsList = pkgList pkgs;
in {
  # Consolidated User CLI, GUI & Desktop Packages
  # (Imported from pkg-list.nix)
  home.packages = pkgsList.cli ++ pkgsList.gui ++ pkgsList.windowManager;
}
