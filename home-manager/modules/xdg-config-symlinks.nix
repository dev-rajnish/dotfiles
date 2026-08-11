{
  config,
  lib,
  pkgs,
  ...
}: let
  dotConfigPath = "${config.home.homeDirectory}/_ws/dotfiles/dot_config";

  # Read dot_config directory entries
  entries = builtins.readDir ../../dot_config;

  # Filter hidden or temporary files
  validEntries = lib.filterAttrs (name: type: name != ".DS_Store" && name != "__pycache__") entries;

  # Symlink dot_config entries to
  # ~/.config via mkOutOfStoreSymlink
  mkConfigEntry = name: type: {
    name = name;
    value = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotConfigPath}/${name}";
    };
  };
in {
  xdg.configFile = lib.mapAttrs' mkConfigEntry validEntries;

  # Backup existing unmanaged config
  # folders in ~/.config before linking
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
