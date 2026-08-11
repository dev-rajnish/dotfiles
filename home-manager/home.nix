{
  lib,
  username,
  homeVersion,
  ...
}: let
  folders = [
    ./fhs-env
    ./pkgs
    ./modules
  ];

  readNixFilesFrom = folder: let
    dir = builtins.readDir folder;
    filterNixFiles = key: value: value == "regular" && lib.hasSuffix ".nix" key;
    toImport = name: _: folder + ("/" + name);
  in
    lib.mapAttrsToList toImport (lib.filterAttrs filterNixFiles dir);

  imports = lib.flatten (map readNixFilesFrom folders);
in {
  inherit imports;

  news = {
    display = "silent";
  };

  home = {
    stateVersion = homeVersion;
    inherit username;
    homeDirectory = "/home/${username}";
    enableNixpkgsReleaseCheck = false;

    sessionVariables = {
      EDITOR = "nvim";
      SHELL = "fish";
      MAN_DISABLE_CACHE = 1;
      SSH_ASKPASS = "";
      GIT_ASKPASS = "";
    };
  };
}
