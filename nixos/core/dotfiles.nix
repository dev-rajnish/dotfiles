# =============================================================================
#  Fresh Install & VM Dotfiles Automatic Initialization
# =============================================================================
{
  username,
  self ? null,
  ...
}: let
  userHome = "/home/${username}";
  targetDir = "${userHome}/_ws/dotfiles";
  flakeSrc =
    if self != null
    then "${self.outPath}"
    else "";
in {
  # ---------------------------------------------------------------------------
  # 🚀 System Activation Script: Bootstrap Full Dotfiles Repo on the fly
  # ---------------------------------------------------------------------------
  system.activationScripts.initDotfiles = {
    text = ''
      TARGET_DIR="${targetDir}"
      USER_NAME="${username}"
      USER_HOME="${userHome}"
      FLAKE_SRC="${flakeSrc}"

      # Ensure base workspace parent directory exists
      mkdir -p "$USER_HOME/_ws"

      # If dotfiles directory does not exist, initialize it with running flake source
      if [ ! -d "$TARGET_DIR" ] && [ -n "$FLAKE_SRC" ] && [ -d "$FLAKE_SRC" ]; then
        echo ":: Initializing dotfiles repository to $TARGET_DIR..."
        mkdir -p "$TARGET_DIR"
        cp -rn "$FLAKE_SRC"/. "$TARGET_DIR/" 2>/dev/null || true
      fi

      # Ensure user ownership and write permissions for out-of-store editing
      if [ -d "$USER_HOME/_ws" ]; then
        chown -R "$USER_NAME":users "$USER_HOME/_ws"
        chmod -R u+rwX "$USER_HOME/_ws"
      fi
    '';
  };
}
