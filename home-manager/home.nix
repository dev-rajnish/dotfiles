{
  lib,
  username,
  homeVersion,
  ...
}: let
  folders = [
    ./wm 
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

  programs = {
    home-manager.enable = true;
    man.enable = false;
  };
  manual.manpages.enable = false;

  news = {
    display = "silent";
  };

  home = {
    stateVersion = homeVersion;
    inherit username;
    homeDirectory = "/home/${username}";
    enableNixpkgsReleaseCheck = false;
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
