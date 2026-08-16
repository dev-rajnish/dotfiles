# =============================================================================
#  Git Version Control & User Credentials
# =============================================================================
{
  ghUsername,
  ghEmail,
  ...
}: {
  # ---------------------------------------------------------------------------
  # 🐙 Git Configuration & Global Settings
  # ---------------------------------------------------------------------------
  programs.git = {
    enable = true;
    settings = {
      # User identity (Imported from var.nix)
      user = {
        name = ghUsername;
        email = ghEmail;
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
