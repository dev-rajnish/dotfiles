# =============================================================================
#  Git Version Control Module (modules/home/git.nix)
# =============================================================================
{
  pkgs,
  env,
  ...
}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = env.ghUsername;
        email = env.ghEmail;
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = false;
      credential.helper = "store";
      merge.conflictstyle = "diff3";
      diff.algorithm = "histogram";
    };
  };
}
