{
  lib,
  username,
  homeVersion,
  ...
}: let
  folders = [
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

  programs = {
    home-manager.enable = true;
    man.enable = false;
  };
  manual.manpages.enable = false;

  home = {
    stateVersion = homeVersion;
    inherit username;
    homeDirectory = "/home/${username}";
    enableNixpkgsReleaseCheck = true;
    pointerCursor.enable = true;

    sessionVariables = {
      EDITOR = "nvim";
      SHELL = "fish";
      MAN_DISABLE_CACHE = 1;
      SSH_ASKPASS = "";
      GIT_ASKPASS = "";
    };
  };

  systemd.user.startServices = "sd-switch";
}
