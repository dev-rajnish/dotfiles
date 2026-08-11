{
  lib,
  systemVersion,
  ...
}: let
  folders = [
    ./core
    ./desktop
    ./hardware
    ./virtualization
  ];

  readNixFilesFrom = folder: let
    dir = builtins.readDir folder;
    filterNixFiles = key: value: value == "regular" && lib.hasSuffix ".nix" key;
    toImport = name: _: folder + ("/" + name);
  in
    lib.mapAttrsToList toImport (lib.filterAttrs filterNixFiles dir);

  imports = lib.flatten (map readNixFilesFrom folders);
in {
  imports = [./hardware-configuration.nix] ++ imports;

  system.stateVersion = systemVersion;
}
