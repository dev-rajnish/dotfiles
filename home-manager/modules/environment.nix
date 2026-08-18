# =============================================================================
#  User Environment, Session Variables & Base Configuration
# =============================================================================
{
  lib,
  env,
  ...
}: {
  # Suppress Home Manager release news popups
  news.display = "silent";

  home = {
    username = env.username;
    homeDirectory = "/home/${env.username}";
    enableNixpkgsReleaseCheck = true;

    # Global User Shell & Editor Session Variables (Populated dynamically from env)
    sessionVariables = {
      EDITOR = env.editor;
      TERMINAL = env.terminal;
      BROWSER = lib.mkDefault env.browser;
      SHELL = "bash";
      MAN_DISABLE_CACHE = 1;
      SSH_ASKPASS = "";
      GIT_ASKPASS = "";
    };
  };
}
