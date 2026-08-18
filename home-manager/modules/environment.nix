# =============================================================================
#  User Environment, Session Variables & Base Configuration
# =============================================================================
{
  lib,
  username,
  editor,
  terminal,
  browser,
  ...
}: {
  # Suppress Home Manager release news popups
  news.display = "silent";

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    enableNixpkgsReleaseCheck = true;

    # Global User Shell & Editor Session Variables
    sessionVariables = {
      EDITOR = editor;
      TERMINAL = terminal;
      BROWSER = lib.mkDefault browser;
      SHELL = "bash";
      MAN_DISABLE_CACHE = 1;
      SSH_ASKPASS = "";
      GIT_ASKPASS = "";
    };
  };
}
