# =============================================================================
#  Git Version Control & User Credentials
# =============================================================================
{env, ...}: {
  # ---------------------------------------------------------------------------
  # 🐙 Git Configuration & Global Settings
  # ---------------------------------------------------------------------------
  programs.git = {
    enable = true;
    settings = {
      # User identity (Imported from env/system.toml)
      user = {
        name = env.ghUsername;
        email = env.ghEmail;
      };

      # Credential helper to cache logins
      credential = {
        helper = "store";
      };

      # Disable GUI askpass prompts in terminal
      core = {
        askPass = "";
      };
    };
  };
}
