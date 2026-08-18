# =============================================================================
#  Fresh Install & VM Dotfiles Automatic Initialization
# =============================================================================
{
  env,
  self ? null,
  ...
}: let
  userHome = "/home/${env.username}";
  targetDir = "${userHome}/${env.dotfilesDir}";
  parentDir = dirOf targetDir;
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
      USER_NAME="${env.username}"
      USER_HOME="${userHome}"
      PARENT_DIR="${parentDir}"
      FLAKE_SRC="${flakeSrc}"

      # Ensure base parent directory exists
      mkdir -p "$PARENT_DIR"

      # If dotfiles directory does not exist, initialize it with running flake source
      if [ ! -d "$TARGET_DIR" ] && [ -n "$FLAKE_SRC" ] && [ -d "$FLAKE_SRC" ]; then
        echo ":: Initializing dotfiles repository to $TARGET_DIR..."
        mkdir -p "$TARGET_DIR"
        cp -rn "$FLAKE_SRC"/. "$TARGET_DIR/" 2>/dev/null || true
      fi

      # Ensure user ownership and write permissions for out-of-store editing
      if [ -d "$PARENT_DIR" ]; then
        chown -R "$USER_NAME":users "$PARENT_DIR"
        chmod -R u+rwX "$PARENT_DIR"
      fi
    '';
  };
}
