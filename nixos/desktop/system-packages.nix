{
  pkgs,
  pkgList,
  ...
}: {
  environment.variables = {
    MAN_DISABLE_CACHE = 1;
  };

  # System-wide Core Packages (Imported from pkg-list.nix -> systemCore)
  environment.systemPackages = (pkgList pkgs).systemCore;
}
