# =============================================================================
#  Out-of-Store Live Config Symlinking (~/.config/*)
# =============================================================================
{
  config,
  lib,
  pkgs,
  dotfilesDir ? "_ws/dotfiles",
  ...
}: let
  # Absolute path to dotfiles/dot_config directory in user's home
  dotConfigPath = "${config.home.homeDirectory}/${dotfilesDir}/dot_config";

  # Read all dot_config directory entries from repository
  entries = builtins.readDir ../../dot_config;

  # Filter out temporary / system metadata files
  validEntries = lib.filterAttrs (name: type: name != ".DS_Store" && name != "__pycache__") entries;

  # Create out-of-store symlink mapping for each config folder
  mkConfigEntry = name: type: {
    name = name;
    value = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotConfigPath}/${name}";
    };
  };
in {
  # ---------------------------------------------------------------------------
  # 🔗 Generate Out-of-Store Live Symlinks in ~/.config/
  # ---------------------------------------------------------------------------
  xdg.configFile = lib.mapAttrs' mkConfigEntry validEntries;

  # ---------------------------------------------------------------------------
  # 🛡️ Pre-Activation Backup Handler for Unmanaged ~/.config Entries
  # ---------------------------------------------------------------------------
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

        # If existing directory is unmanaged, backup safely with timestamp
        if [ "$is_managed" -eq 0 ]; then
          backup_target="$HOME/.config/$item.hm.backup-$timestamp"
          echo "Backing up unmanaged folder/file $target to $backup_target"
          run mv "$target" "$backup_target"
        fi
      fi
    done
  '';
}
