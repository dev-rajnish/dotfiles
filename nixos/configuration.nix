# =============================================================================
#  NixOS Main Entrypoint & Dynamic Sub-Module Importer
# =============================================================================
{
  lib,
  systemVersion,
  ...
}: let
  # Subdirectories containing modular NixOS configuration files
  folders = [
    ./core
    ./desktop
    ./hardware
    ./virtualization
  ];

  # Helper: Recursively load all regular `.nix` files inside specified directory
  readNixFilesFrom = folder: let
    dir = builtins.readDir folder;
    filterNixFiles = key: value: value == "regular" && lib.hasSuffix ".nix" key;
    toImport = name: _: folder + ("/" + name);
  in
    lib.mapAttrsToList toImport (lib.filterAttrs filterNixFiles dir);

  # Flatten all imported nix files across all folders
  imports = lib.flatten (map readNixFilesFrom folders);
in {
  # Import host hardware-configuration along with all sub-modules
  imports = [./hardware-configuration.nix] ++ imports;

  # NixOS State Version (Matches var.nix)
  system.stateVersion = systemVersion;
}
