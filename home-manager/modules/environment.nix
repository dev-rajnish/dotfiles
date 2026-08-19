# =============================================================================
#  User Environment, Session Variables & Base Configuration
# =============================================================================
{
  config,
  pkgs,
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
      SHELL = "${pkgs.fish}/bin/fish";
      MAN_DISABLE_CACHE = 1;
      SSH_ASKPASS = "";
      GIT_ASKPASS = "";
    };

    sessionPath = [
      "${config.home.homeDirectory}/shoelace/bin"
    ];
  };
}
