# =============================================================================
#  Fresh Install & VM Dotfiles Automatic Initialization
# =============================================================================
{username, ...}: let
  # Captures the entire dotfiles repository from the flake root into the Nix store
  dotfilesSrc = ../../.;
  userHome = "/home/${username}";
  targetDir = "${userHome}/_ws/dotfiles";
in {
  # ---------------------------------------------------------------------------
  # 🚀 System Activation Script: Bootstrap Full Dotfiles Repo
  # ---------------------------------------------------------------------------
  system.activationScripts.initDotfiles = {
    text = ''
      TARGET_DIR="${targetDir}"
      USER_NAME="${username}"
      USER_HOME="${userHome}"

      # Ensure base workspace parent directory exists
      mkdir -p "$USER_HOME/_ws"

      # If dotfiles directory does not exist, initialize it with full repository from Nix store
      if [ ! -d "$TARGET_DIR" ]; then
        echo ":: Initializing full dotfiles repository from Nix store to $TARGET_DIR..."
        mkdir -p "$TARGET_DIR"
        cp -rn ${dotfilesSrc}/. "$TARGET_DIR/" || true
      else
        # Copy any missing files/directories without overwriting existing working copies
        cp -rn ${dotfilesSrc}/. "$TARGET_DIR/" 2>/dev/null || true
      fi

      # Ensure user ownership and write permissions for out-of-store editing
      chown -R "$USER_NAME":users "$USER_HOME/_ws"
      chmod -R u+rwX "$USER_HOME/_ws"
    '';
  };
}
