{
  lib,
  username,
  home-version,
  ...
}:
#MULTIPLE FOLDERS
let
  folders = [
    ./pkgs
  ];

  readNixFilesFrom = folder: let
    dir = builtins.readDir folder;
    filterCaches = key: value: value == "regular" && lib.hasSuffix ".nix" key;
    toImport = name: _: folder + ("/" + name);
  in
    lib.mapAttrsToList toImport (lib.filterAttrs filterCaches dir);
  imports = lib.flatten (map readNixFilesFrom folders);
in {
  ## config start
  inherit imports;

  programs = {
    home-manager.enable = true;
    man.enable = false;
  };
  manual.manpages.enable = false;

  home = {
    stateVersion = "${home-version}";
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables = {
      EDITOR = "nvim";
      SHELL = "fish";
      MAN_DISABLE_CACHE = 1;
    };
  };

  systemd.user.startServices = "sd-switch";
}
# SINGLE FOLDER
/*
let
  folder = ./modules;
  toImport = name: value: folder + ("/" + name);
  filterCaches = key: value: value == "regular" && lib.hasSuffix ".nix" key;
  imports = lib.mapAttrsToList toImport (lib.filterAttrs filterCaches (builtins.readDir folder));
in
{
  inherit imports;
*/

