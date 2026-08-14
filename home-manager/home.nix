# =============================================================================
#  Home Manager Main Entrypoint & Dynamic Sub-Module Importer
# =============================================================================
{
  lib,
  username,
  homeVersion,
  ...
}: let
  # Subdirectories containing modular Home Manager configuration files
  folders = [
    ./pkgs
    ./modules
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
  # Dynamically imported modules & standalone package derivations
  inherit imports;

  # Suppress Home Manager release news popups
  news = {
    display = "silent";
  };

  # ---------------------------------------------------------------------------
  # 👤 User Environment & Session Variables
  # ---------------------------------------------------------------------------
  home = {
    stateVersion = homeVersion;
    inherit username;
    homeDirectory = "/home/${username}";
    enableNixpkgsReleaseCheck = false;

    # Global User Shell & Editor Variables
    sessionVariables = {
      EDITOR = "nvim";
      SHELL = "fish";
      MAN_DISABLE_CACHE = 1;
      SSH_ASKPASS = "";
      GIT_ASKPASS = "";
    };
  };
}
