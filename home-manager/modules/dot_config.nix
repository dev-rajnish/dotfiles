{
  config,
  lib,
  pkgs,
  ...
}: let
  dotConfigPath = "${config.home.homeDirectory}/_ws/dotfiles/dot_config";

  # Read all files and subdirectories in dot_config
  entries = builtins.readDir ../../dot_config;

  # Filter out unwanted entries if any (e.g., hidden temp files or __pycache__)
  validEntries = lib.filterAttrs (name: type: name != ".DS_Store" && name != "__pycache__") entries;

  # Map each entry in dot_config to xdg.configFile.<name> using mkOutOfStoreSymlink
  # This creates direct out-of-store symlinks to ~/ws/dotfiles/dot_config/<name>,
  # allowing instant live editing without rebuilding and providing blazing fast Nix evaluation.
  mkConfigEntry = name: type: {
    name = name;
    value = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotConfigPath}/${name}";
    };
  };
in {
  xdg.configFile = lib.mapAttrs' mkConfigEntry validEntries;

  # If a target folder/file exists in ~/.config:
  # Check if it contains any files/symlinks managed by Home Manager.
  # If NO Home Manager symlinks are found, back up the whole folder to pkg-folder.hm.backup-date-time.
  home.activation.backupExistingDotConfig = lib.hm.dag.entryBefore ["linkGeneration"] ''
    run mkdir -p "$HOME/.config"
    timestamp=$(date +%Y%m%d-%H%M%S)

    for item in ${lib.concatStringsSep " " (builtins.attrNames validEntries)}; do
      target="$HOME/.config/$item"
      if [ -e "$target" ] || [ -L "$target" ]; then
        is_managed=0

        if [ -L "$target" ]; then
          link_dest=$(readlink "$target")
          case "$link_dest" in
            /nix/store/*|"${dotConfigPath}"/*|"${dotConfigPath}/$item")
              is_managed=1
              ;;
          esac
        elif [ -d "$target" ]; then
          if find "$target" -type l \( -lname '/nix/store/*' -o -lname "${dotConfigPath}/*" \) | grep -q .; then
            is_managed=1
          fi
        fi

        if [ "$is_managed" -eq 0 ]; then
          backup_target="$HOME/.config/$item.hm.backup-$timestamp"
          echo "Backing up unmanaged folder/file $target to $backup_target"
          run mv "$target" "$backup_target"
        fi
      fi
    done
  '';
}
