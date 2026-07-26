{
  lib,
  system-version,
  ...
}:
#MULTIPLE FOLDERS
let
  folders = [
    ./modules
    ./sys-pkgs
  ];

  readNixFilesFrom = folder: let
    dir = builtins.readDir folder;
    filterCaches = key: value: value == "regular" && lib.hasSuffix ".nix" key;
    toImport = name: _: folder + ("/" + name);
  in
    lib.mapAttrsToList toImport (lib.filterAttrs filterCaches dir);
  imports = lib.flatten (map readNixFilesFrom folders);
in {
  #==config start
  imports = [./hardware-configuration.nix] ++ imports;

  #
  system.stateVersion = "${system-version}";
}
